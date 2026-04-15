import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/resume_service.dart';
import 'dart:async';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobService _jobService = JobService();
  final ResumeService _resumeService = ResumeService();
  
  List<Map<String, dynamic>> _allJobs = [];
  List<Map<String, dynamic>> _filteredJobs = [];
  List<String> _userSkills = [];
  Map<String, dynamic>? _lastResumeData;
  Set<String> _appliedJobs = {};
  String _userName = "";
  bool _isLoading = true;
  String _searchQuery = "";
  StreamSubscription? _jobsSubscription;
  StreamSubscription? _resumeSubscription;

  // Filter values
  String _selectedType = 'All';
  String _selectedSalaryRange = 'All';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    setState(() => _isLoading = true);
    
    // Listen to resume changes
    _resumeSubscription = _resumeService.getLatestResumeAnalysisStream().listen((data) {
      if (mounted) {
        setState(() {
          if (data != null) {
            _lastResumeData = data;
            _userSkills = List<String>.from(data['skills'] ?? []);
            _userName = data['name'] ?? "";
          }
          _processJobs();
        });
      }
    });

    // Listen to job changes
    _jobsSubscription = _jobService.getAllActiveJobsStream().listen((jobs) {
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _processJobs();
          _isLoading = false;
        });
      }
    });

    // Listen to my applications to update "Apply" button status
    _jobService.getMyApplicationsStream().listen((appliedJobIds) {
      if (mounted) {
        setState(() {
          _appliedJobs = appliedJobIds.toSet();
        });
      }
    });
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    _resumeSubscription?.cancel();
    super.dispose();
  }

  void _processJobs() {
    _filteredJobs = _allJobs.map((job) {
      List<String> requiredSkills = List<String>.from(job['requiredSkills'] ?? []);
      int score = _calculateMatchScore(_userSkills, requiredSkills);
      
      return {
        ...job,
        'matchScore': score,
        'tags': requiredSkills, // Map requiredSkills to tags for UI
        'isHot': score >= 90, // Example: jobs with high match are "hot" for the user
      };
    }).toList();

    // Sort by match score descending
    _filteredJobs.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));

    // Apply search filter if any
    if (_searchQuery.isNotEmpty) {
      _filteredJobs = _filteredJobs.where((job) {
        final title = job['title'].toString().toLowerCase();
        final company = job['company'].toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) || 
               company.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply Advanced Filters
    if (_selectedType != 'All') {
      _filteredJobs = _filteredJobs.where((job) => job['type'] == _selectedType).toList();
    }
    
    // Salary filter is harder because it's a string, we'll do a simple range match if possible
    if (_selectedSalaryRange != 'All') {
      // Example: "$1000 - $2000"
      _filteredJobs = _filteredJobs.where((job) {
        final salary = job['salaryRange'] ?? "";
        return salary.contains(_selectedSalaryRange); 
      }).toList();
    }
  }

  int _calculateMatchScore(List<String> userSkills, List<String> targetSkills) {
    if (targetSkills.isEmpty) return 100;
    if (userSkills.isEmpty) return 0;
    
    int matches = 0;
    for (var target in targetSkills) {
      if (userSkills.any((user) => user.toLowerCase().contains(target.toLowerCase()) || 
                                   target.toLowerCase().contains(user.toLowerCase()))) {
        matches++;
      }
    }
    return ((matches / targetSkills.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width >= 1100;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isWeb),
          const SizedBox(height: 32),
          _buildSearchBar(),
          const SizedBox(height: 32),
          Text(
            isWeb ? 'Recommended for You' : 'Top Recommendations',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _filteredJobs.isEmpty
              ? _buildEmptyState()
              : isWeb
                  ? _buildWebJobGrid()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) => _buildJobCard(_filteredJobs[index]),
                    ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName.isNotEmpty ? 'Jobs for $_userName' : 'Explore Opportunities',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              _userSkills.isNotEmpty 
                ? 'Matched with ${_userSkills.length} skills from your resume'
                : 'Upload your resume for better job matches',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
        if (isWeb)
          ElevatedButton.icon(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Advanced Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Advanced Filters', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterDropdown(
                'Job Type', 
                _selectedType, 
                ['All', 'Full-time', 'Part-time', 'Contract', 'Remote'],
                (val) => setDialogState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              _buildFilterDropdown(
                'Salary Range', 
                _selectedSalaryRange, 
                ['All', '\$500', '\$1000', '\$2000', '\$3000'],
                (val) => setDialogState(() => _selectedSalaryRange = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _processJobs();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E293B),
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _processJobs();
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search for jobs, companies, or keywords...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF6366F1)),
          hintStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.work_outline, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No jobs available right now' : 'No matching jobs found',
            style: const TextStyle(color: Colors.white60, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildWebJobGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredJobs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) => _buildJobCard(_filteredJobs[index]),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    bool isHot = job['isHot'];
    int score = job['matchScore'];

    return Container(
      height: 220, // Added fixed height for mobile consistency
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: job['image'] != null
                      ? Image.network(job['image'], fit: BoxFit.cover)
                      : Image.network(
                          'https://api.dicebear.com/7.x/initials/png?seed=${job['company']}',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          job['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (isHot)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'HOT',
                              style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job['company']} • ${job['location']}',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(color: _getScoreColor(score), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text('Match', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              ...(job['tags'] as List<String>).map((tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  )),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job['salaryRange'] ?? 'Negotiable',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildApplyButton(job),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(Map<String, dynamic> job) {
    String jobId = job['id'];
    bool applied = _appliedJobs.contains(jobId);

    return ElevatedButton(
      onPressed: applied ? null : () => _handleApply(job),
      style: ElevatedButton.styleFrom(
        backgroundColor: applied ? Colors.white10 : const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(applied ? 'Applied' : 'Apply Now'),
    );
  }

  Future<void> _handleApply(Map<String, dynamic> job) async {
    if (_lastResumeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume first!')),
      );
      return;
    }

    final success = await _jobService.applyForJob(
      jobId: job['id'],
      resumeData: _lastResumeData!,
    );

    if (success && mounted) {
      setState(() {
        _appliedJobs.add(job['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully applied for ${job['title']}!')),
      );
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
