import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../widgets/resume_thematic_viewer.dart';
import '../widgets/candidate_avatar.dart';
import 'post_job_screen.dart';
import '../widgets/hoverable_card.dart';
import '../utils/pdf_generator.dart';
import '../features/mock_interview/screens/interview_results_screen.dart';
import '../features/mock_interview/models/interview_session.dart';

class EmployerDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  const EmployerDashboardScreen({super.key, this.isDarkMode = true});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  final Set<String> _selectedApplicantIds = {};

  Color get _textColor => widget.isDarkMode ? Colors.white : Colors.black87;
  Color get _mutedText => widget.isDarkMode ? Colors.white60 : Colors.black54;
  Color get _cardBg => widget.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white;
  Color get _cardBorder => widget.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300;
  bool get isDarkMode => widget.isDarkMode;
  late final JobService _jobService;
  late final Stream<Map<String, int>> _statsStream;
  late final Stream<List<Map<String, dynamic>>> _jobsStream;
  late final Stream<List<Map<String, dynamic>>> _applicantsStream;

  @override
  void initState() {
    super.initState();
    _jobService = JobService();
    _statsStream = _jobService.getEmployerStatsStream();
    _jobsStream = _jobService.getEmployerJobsStream();
    _applicantsStream = _jobService.getEmployerAllApplicantsStream();
  }

  void _showPostJobDialog(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1100;

    if (isMobile) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const PostJobScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: PostJobScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 32,
        isMobile ? 16 : 8, // Reduced top padding
        isMobile ? 20 : 32,
        isMobile ? 28 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile),
          const SizedBox(height: 32),
          _buildSectionHeader('Your Activity'),
          const SizedBox(height: 16),

          StreamBuilder<Map<String, int>>(
            stream: _statsStream,
            builder: (context, snapshot) {
              final stats =
                  snapshot.data ?? {'activeJobs': 0, 'totalApplicants': 0};
              return _buildStatsRow(isMobile, stats);
            },
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              const Icon(Icons.work_outline, color: Color(0xFF6366F1), size: 28),
              const SizedBox(width: 12),
              Text(
                'Your Job Postings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _jobsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                );
              }
              if (snapshot.hasError) {
                return const Text(
                  'Error loading jobs',
                  style: TextStyle(color: Colors.red),
                );
              }
              final allJobs = snapshot.data ?? [];
              if (allJobs.isEmpty) {
                return _buildEmptyState(context);
              }
              // Only show the latest job
              final latestJob = [allJobs.first];
              return _buildJobsList(isMobile, latestJob);
            },
          ),

          const SizedBox(height: 32),
          Text(
            'Your Top Applicants',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _jobsStream,
            builder: (context, jobSnapshot) {
              final jobs = jobSnapshot.data ?? [];
              final List<String> employerSkills = jobs
                  .expand((j) => List<String>.from(j['requiredSkills'] ?? []))
                  .toSet()
                  .toList();

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _applicantsStream,
                builder: (context, applicantSnapshot) {
                  final allApplicants = applicantSnapshot.data ?? [];

                  // Matching logic: compare applicant skills with job requirements
                  List<Map<String, dynamic>> matchedCandidates = allApplicants
                      .map((a) {
                        final resumeData = a['resumeData'] ?? {};
                        final skills = List<String>.from(
                          resumeData['skills'] ?? [],
                        );

                        int matches = 0;
                        for (var s in skills) {
                          if (employerSkills.any(
                            (es) => es.toLowerCase() == s.toLowerCase(),
                          )) {
                            matches++;
                          }
                        }
                        double score = skills.isEmpty
                            ? 0
                            : (matches / employerSkills.length.clamp(1, 100)) *
                                  100;

                        return {
                          ...a,
                          'name': a['seekerName'],
                          'jobTitle': a['jobTitle'] ?? 'Unknown Position',
                          'category': resumeData['category'] ?? 'Professional',
                          'skills': skills,
                          'matchScore': score.toStringAsFixed(0),
                          'profilePictureUrl': resumeData['profilePictureUrl'],
                          'seekerId': a['seekerId'],
                        };
                      })
                      .toList();

                  matchedCandidates.sort(
                    (a, b) => double.parse(
                      b['matchScore'],
                    ).compareTo(double.parse(a['matchScore'])),
                  );

                  if (matchedCandidates.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          'No applicants yet',
                          style: TextStyle(color: _mutedText),
                        ),
                      ),
                    );
                  }
                  return _buildCandidateTable(
                    context,
                    isMobile,
                    matchedCandidates,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: _mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No job postings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post your first job to start receiving candidates',
            style: TextStyle(color: _mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(bool isMobile, List<Map<String, dynamic>> jobs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final skills = List<String>.from(job['requiredSkills'] ?? []);

        return HoverableCard(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cardBorder),
              boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'Job Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job['location'] ?? 'Remote'} • ${job['type'] ?? 'Full-time'}',
                          style: TextStyle(
                            color: _mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job['status'] == 'active'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (job['status']?.toString() ?? 'active').toUpperCase(),
                      style: TextStyle(
                        color: job['status'] == 'active'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                job['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ...skills
                      .take(3)
                      .map(
                        (s) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              color: _mutedText,
                            ),
                          ),
                        ),
                      ),
                  if (skills.length > 3)
                    Text(
                      '+${skills.length - 3} more',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    job['salaryRange'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recruitment Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _textColor,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Manage your job postings and top talent',
            style: TextStyle(color: _mutedText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPostJobDialog(context),
              icon: const Icon(Icons.post_add, color: Colors.white, size: 20),
              label: const Text(
                'Post a New Job',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recruitment Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Manage your job postings and top talent',
                style: TextStyle(color: _mutedText),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showPostJobDialog(context),
          icon: const Icon(Icons.post_add, color: Colors.white, size: 20),
          label: const Text(
            'Post a New Job',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _textColor,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile, Map<String, int> stats) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                'Active Jobs',
                stats['activeJobs'].toString(),
                Icons.business_center,
                Colors.blue,
                _generateDynamicTrend(stats['activeJobs']!.toDouble(), 8),
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Total Applicants',
                stats['totalApplicants'].toString(),
                Icons.people,
                Colors.purple,
                _generateDynamicTrend(stats['totalApplicants']!.toDouble(), 8),
                isBarChart: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Avg. Match',
                '84%',
                Icons.auto_awesome,
                Colors.green,
                _generateDynamicTrend(84, 8),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        _buildStatCard(
          'Active Jobs',
          stats['activeJobs'].toString(),
          Icons.business_center,
          Colors.blue,
          _generateDynamicTrend(stats['activeJobs']!.toDouble(), 8),
          isBarChart: false,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          'Total Applicants',
          stats['totalApplicants'].toString(),
          Icons.people,
          Colors.purple,
          _generateDynamicTrend(stats['totalApplicants']!.toDouble(), 8),
          isBarChart: true,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          'Average Match',
          '84%',
          Icons.auto_awesome,
          Colors.green,
          _generateDynamicTrend(84, 8),
          isBarChart: false,
        ),
      ],
    );
  }

  List<double> _generateDynamicTrend(double currentValue, int points) {
    final List<double> trend = [];
    // Always trend upwards to the current value
    for (int i = 0; i < points; i++) {
      double factor = (i + 1) / points;
      // Progressive growth towards currentValue
      double val = currentValue * factor;
      trend.add(val);
    }
    return trend;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    List<double> dataPoints, {
    bool isBarChart = false,
  }) {
    return Expanded(
      child: HoverableCard(
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cardBorder),
            boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background Graphical Element
                Positioned(
                  bottom: -10,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: CustomPaint(
                    painter: isBarChart
                        ? _BarChartPainter(dataPoints, color.withValues(alpha: 0.2))
                        : _MiniChartPainter(dataPoints, color.withValues(alpha: 0.3)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          Icon(Icons.trending_up, color: color.withValues(alpha: 0.5), size: 16),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: _mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulkActions(List<Map<String, dynamic>> candidates) {
    bool allSelected = candidates.isNotEmpty &&
        candidates.every((c) => _selectedApplicantIds.contains(c['seekerId']));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            activeColor: const Color(0xFF6366F1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedApplicantIds.addAll(
                    candidates.map((c) => c['seekerId'] as String),
                  );
                } else {
                  _selectedApplicantIds.clear();
                }
              });
            },
          ),
          Text(
            'Select All Applicants',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (_selectedApplicantIds.isNotEmpty)
            ElevatedButton.icon(
            onPressed: () => _handleBulkDownload(candidates),
              icon: const Icon(Icons.download_for_offline, size: 18),
              label: Text('Download (${_selectedApplicantIds.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCandidateTable(
    BuildContext context,
    bool isMobile,
    List<Map<String, dynamic>> candidates,
  ) {
    if (isMobile) {
      return Column(
        children: [
          _buildBulkActions(candidates),
          ...candidates.take(5).map((c) {
            final skills = List<String>.from(c['skills'] ?? []);
            final score = '${c['matchScore']}%';
            final name = c['name'] ?? 'Candidate';
            final role = c['jobTitle'] ?? 'N/A';
            final isSelected = _selectedApplicantIds.contains(c['seekerId']);

            return HoverableCard(
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                        : _cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedApplicantIds.add(c['seekerId']);
                              } else {
                                _selectedApplicantIds.remove(c['seekerId']);
                              }
                            });
                          },
                        ),
                        CandidateAvatar(
                          seekerId: c['seekerId'] ?? '',
                          seekerName: name,
                          radius: 20,
                          initialPictureUrl: c['profilePictureUrl'],
                        ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Applied for: $role',
                            style: TextStyle(
                              color: _mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        score,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: skills
                      .take(4)
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              color: _mutedText,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final applicantFormat = {
                            'seekerName': c['seekerName'] ?? name,
                            'seekerEmail':
                                c['seekerEmail'] ?? 'Contact information hidden',
                            'resumeData': c['resumeData'] ?? {},
                            'profilePictureUrl': c['profilePictureUrl'],
                            'seekerId': c['seekerId'],
                          };
                          showDialog(
                            context: context,
                            builder: (context) => ResumeThematicViewer(
                              applicant: applicantFormat,
                              theme: 'Modern',
                              primaryColor: const Color(0xFF6366F1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ).withValues(alpha: 0.2),
                          foregroundColor: const Color(0xFF818CF8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => _handleDownload(c),
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF818CF8)),
                        tooltip: 'Download Resume',
                      ),
                    ),
                    if (c['hasInterview'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _showInterviewResults(context, c),
                          icon: const Icon(Icons.video_call_rounded, color: Colors.green),
                          tooltip: 'View Interview Results',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

    // Web – full DataTable
    return Column(
      children: [
        _buildBulkActions(candidates),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cardBorder),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 40,
                    horizontalMargin: 24,
                    headingRowHeight: 64,
                    dataRowMinHeight: 76,
                    dataRowMaxHeight: 76,
                    columns: [
                      _buildTableHeader('Select'),
                      _buildTableHeader('Candidate Name'),
                      _buildTableHeader('Applied For'),
                      _buildTableHeader('Skills'),
                      _buildTableHeader('Match'),
                      _buildTableHeader('Action'),
                    ],
                    rows: candidates.take(5).map((c) {
                      final skills = List<String>.from(c['skills'] ?? []);
                      return _buildCandidateRow(
                        context,
                        c['name'] ?? 'Candidate',
                        c['jobTitle'] ?? 'N/A',
                        skills,
                        '${c['matchScore']}%',
                        c,
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  DataColumn _buildTableHeader(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: _mutedText,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  DataRow _buildCandidateRow(
    BuildContext context,
    String name,
    String role,
    List<String> skills,
    String score,
    Map<String, dynamic> candidate,
  ) {
    final isSelected = _selectedApplicantIds.contains(candidate['seekerId']);
    return DataRow(
      selected: isSelected,
      cells: [
        DataCell(
          Checkbox(
            value: isSelected,
            activeColor: const Color(0xFF6366F1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedApplicantIds.add(candidate['seekerId']);
                } else {
                  _selectedApplicantIds.remove(candidate['seekerId']);
                }
              });
            },
          ),
        ),
        DataCell(
          Row(
            children: [
              CandidateAvatar(
                seekerId: candidate['seekerId'] ?? '',
                seekerName: name,
                radius: 18,
                initialPictureUrl: candidate['profilePictureUrl'],
              ),
              const SizedBox(width: 14),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            role,
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.8),
              fontSize: 15,
            ),
          ),
        ),
        DataCell(
          Row(
            children: skills
                .take(3)
                .map(
                  (s) => Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 11,
                        color: _mutedText,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  // Correctly pass the nested resumeData instead of the entire document as resumeData
                  final applicantFormat = {
                    'seekerName': candidate['seekerName'] ?? name,
                    'seekerEmail':
                        candidate['seekerEmail'] ?? 'Contact information hidden',
                    'resumeData': candidate['resumeData'] ?? {},
                    'profilePictureUrl': candidate['profilePictureUrl'],
                    'seekerId': candidate['seekerId'],
                  };

                  showDialog(
                    context: context,
                    builder: (context) => ResumeThematicViewer(
                      applicant: applicantFormat,
                      theme: 'Modern',
                      primaryColor: const Color(0xFF6366F1),
                    ),
                  );
                },
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (candidate['hasInterview'] == true) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showInterviewResults(context, candidate),
                  icon: const Icon(Icons.video_call_rounded, color: Colors.green, size: 22),
                  tooltip: 'View Interview Results',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _handleDownload(candidate),
                icon: const Icon(Icons.download_rounded, color: Color(0xFF818CF8), size: 20),
                tooltip: 'Download Resume',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleDownload(Map<String, dynamic> candidate) async {
    final name = candidate['name'] ?? 'Candidate';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text('Generating PDF for $name...'),
          ],
        ),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await PdfGenerator.generateAndDownloadResume(
        name: name,
        jobTitle: candidate['jobTitle'] ?? 'N/A',
        email: candidate['seekerEmail'] ?? 'N/A',
        resumeData: candidate['resumeData'] ?? {},
        seekerId: candidate['seekerId'],
      );
    } catch (e) {
      debugPrint('PDF generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF. Please restart the app.')),
        );
      }
    }
  }

  void _handleBulkDownload(List<Map<String, dynamic>> candidates) async {
    final selectedCandidates = candidates.where((c) => _selectedApplicantIds.contains(c['seekerId'])).toList();
    
    if (selectedCandidates.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preparing ${selectedCandidates.length} resumes...'),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await PdfGenerator.generateBulkResumes(selectedCandidates);
    } catch (e) {
      debugPrint('Bulk PDF error: $e');
    }

    if (mounted) {
      setState(() {
        _selectedApplicantIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bulk download complete'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInterviewResults(BuildContext context, Map<String, dynamic> candidate) {
    if (candidate['interviewResult'] == null) return;

    try {
      final session = InterviewSession.fromMap(candidate['interviewResult']);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InterviewResultsScreen(
            session: session,
            onExit: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading interview results: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load interview results.')),
      );
    }
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  _MiniChartPainter(this.dataPoints, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (dataPoints.isEmpty) return;

    final double stepX = size.width / (dataPoints.length - 1);
    final double maxY = dataPoints.reduce((a, b) => a > b ? a : b);
    final double minY = dataPoints.reduce((a, b) => a < b ? a : b);
    final double range = maxY - minY == 0 ? 1 : maxY - minY;

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((dataPoints[i] - minY) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add gradient area
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  _BarChartPainter(this.dataPoints, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (dataPoints.isEmpty) return;

    final double barWidth = size.width / (dataPoints.length * 1.5);
    final double spacing = barWidth / 2;
    final double maxY = dataPoints.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * (barWidth + spacing) + spacing;
      final double barHeight = (dataPoints[i] / maxY) * size.height;
      final double y = size.height - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
