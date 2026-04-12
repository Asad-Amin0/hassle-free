import 'package:flutter/material.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final List<Map<String, dynamic>> _jobs = [
    {
      'title': 'Senior Python Developer',
      'company': 'TechStream AI',
      'location': 'Lahore, Pakistan',
      'salary': '\$1200 - \$2000',
      'matchScore': 95,
      'type': 'Full-time',
      'image': 'https://api.dicebear.com/7.x/initials/png?seed=TS',
      'tags': ['Python', 'Django', 'FastAPI'],
      'isHot': true,
    },
    {
      'title': 'Flutter Mobile Engineer',
      'company': 'InnoSoft',
      'location': 'Remote',
      'salary': '\$800 - \$1500',
      'matchScore': 88,
      'type': 'Contract',
      'image': 'https://api.dicebear.com/7.x/initials/png?seed=IN',
      'tags': ['Flutter', 'Firebase', 'Dart'],
      'isHot': false,
    },
    {
      'title': 'AI/ML Engineer',
      'company': 'CloudNexus',
      'location': 'Islamabad, Pakistan',
      'salary': '\$1500 - \$2500',
      'matchScore': 92,
      'type': 'Full-time',
      'image': 'https://api.dicebear.com/7.x/initials/png?seed=CN',
      'tags': ['PyTorch', 'NLP', 'Docker'],
      'isHot': true,
    },
    {
      'title': 'Frontend Developer (React)',
      'company': 'PixelPerfect',
      'location': 'Karachi, Pakistan',
      'salary': '\$1000 - \$1800',
      'matchScore': 75,
      'type': 'Full-time',
      'image': 'https://api.dicebear.com/7.x/initials/png?seed=PP',
      'tags': ['React', 'Redux', 'Tailwind'],
      'isHot': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width >= 1100;

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
          isWeb
              ? _buildWebJobGrid()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
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
            const Text(
              'Explore Opportunities',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'AI matched jobs based on your parsed skills',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
        if (isWeb)
          ElevatedButton.icon(
            onPressed: () {},
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for jobs, companies, or keywords...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF6366F1)),
          hintStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildWebJobGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _jobs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
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
                  image: DecorationImage(image: NetworkImage(job['image']), fit: BoxFit.cover),
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
              Text(
                job['salary'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
