import 'package:flutter/material.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1100;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 32),
          _buildStatsRow(isMobile),
          const SizedBox(height: 32),
          const Text(
            'Top Candidate Recommendations',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildCandidateTable(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recruitment Overview',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Manage your job postings and top talent',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text('Post a New Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const Text(
                'Recruitment Overview',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Manage your job postings and top talent',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Post a New Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _buildStatCard('Active Jobs', '12', Icons.business_center, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Total Applicants', '458', Icons.people, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Interviews', '24', Icons.calendar_today, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('Avg. Match', '84%', Icons.auto_awesome, Colors.green),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        _buildStatCard('Active Jobs', '12', Icons.business_center, Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard('Total Applicants', '458', Icons.people, Colors.purple),
        const SizedBox(width: 20),
        _buildStatCard('Interviews Scheduled', '24', Icons.calendar_today, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Average Match', '84%', Icons.auto_awesome, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              value, 
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: -1,
              )
            ),
            Text(
              title, 
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateTable(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 40,
          horizontalMargin: 24,
          headingRowHeight: 64,
          dataRowMinHeight: 72,
          dataRowMaxHeight: 72,
          columns: [
            _buildTableHeader('Candidate Name'),
            _buildTableHeader('Role'),
            _buildTableHeader('Skills'),
            _buildTableHeader('Score'),
            _buildTableHeader('Status'),
            _buildTableHeader('Action'),
          ],
          rows: [
            _buildCandidateRow('Muhammad Abdullah', 'Python Developer', ['Python', 'AI', 'NLP'], '9.2', 'Recommended'),
            _buildCandidateRow('Haris Naeem', 'Mobile Developer', ['Flutter', 'Dart', 'Firebase'], '8.8', 'Interested'),
            _buildCandidateRow('Ali Hassan', 'DevOps Engineer', ['AWS', 'Docker', 'K8s'], '8.5', 'In Review'),
            _buildCandidateRow('Waleed Tariq', 'Data Analyst', ['NLP', 'Pandas', 'ML'], '8.2', 'Shortlisted'),
          ],
        ),
      ),
    );
  }

  DataColumn _buildTableHeader(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  DataRow _buildCandidateRow(String name, String role, List<String> skills, String score, String status) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$name'),
              ),
            ),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        )),
        DataCell(Text(role, style: TextStyle(color: Colors.white.withValues(alpha: 0.8)))),
        DataCell(Row(
          children: skills.map((s) => Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          )).toList(),
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score, 
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        )),
        DataCell(Text(
          status, 
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
        )),
        DataCell(TextButton(
          onPressed: () {}, 
          child: const Text(
            'View Profile',
            style: TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.bold),
          )
        )),
      ]
    );
  }
}
