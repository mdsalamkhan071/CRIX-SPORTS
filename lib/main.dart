
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

const gold = Color(0xFFD8B56B);
const bg = Color(0xFF080D18);
const card = Color(0xFF131F31);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabasePublishableKey,
  );

  runApp(const CrixSportsApp());
}

final supabase = Supabase.instance.client;

class CrixSportsApp extends StatelessWidget {
  const CrixSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRIX SPORTS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(primary: gold),
      ),
      home: const MainScreen(),
    );
  }
}

// MAIN NAVIGATION

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selected = 0;

  final pages = const [
    HomePage(),
    MatchesPage(),
    TeamsPage(),
    NewsPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: card,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(() => selected = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_cricket),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

// COMMON HEADER

class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 50, 18, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: gold,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// HOME PAGE

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: gold,
      onRefresh: () async {
        await Future.wait([
          supabase.from('matches').select().limit(20),
          supabase.from('teams').select().limit(20),
        ]);
      },
      child: ListView(
        children: [
          const AppHeader('CRIX SPORTS'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'BEYOND THE GAME.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Your Ultimate Cricket Destination',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          const SectionTitle('MATCH CENTRE'),
          const MatchesList(limit: 3),
          const SectionTitle('EXPLORE CRICKET'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                FeatureCard(Icons.sports_cricket, 'Live Matches'),
                FeatureCard(Icons.calendar_month, 'Fixtures'),
                FeatureCard(Icons.groups, 'Teams'),
                FeatureCard(Icons.person, 'Players'),
                FeatureCard(Icons.newspaper, 'Cricket News'),
                FeatureCard(Icons.analytics, 'Statistics'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'CRIX SPORTS • BEYOND THE GAME',
              textAlign: TextAlign.center,
              style: TextStyle(color: gold),
            ),
          ),
        ],
      ),
    );
  }
}

// MATCHES PAGE

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        AppHeader('MATCH CENTRE'),
        SectionTitle('ALL MATCHES'),
        MatchesList(),
      ],
    );
  }
}

// DATABASE MATCHES

class MatchesList extends StatelessWidget {
  final int? limit;

  const MatchesList({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('matches')
          .select()
          .order('match_date', ascending: true)
          .limit(limit ?? 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: gold),
            ),
          );
        }

        if (snapshot.hasError) {
          return ErrorCard(message: snapshot.error.toString());
        }

        final matches = snapshot.data ?? [];

        if (matches.isEmpty) {
          return const EmptyCard(
            message: 'No matches available yet.',
          );
        }

        return Column(
          children: matches.map((match) {
            return MatchCard(match: match);
          }).toList(),
        );
      },
    );
  }
}

// MATCH CARD

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final title = match['match_title'] ?? 'Cricket Match';
    final status = match['status'] ?? 'upcoming';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailsPage(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 5, 16, 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF29384D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match['tournament'] ?? 'CRIX CRICKET',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  status.toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title.toString(),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Match Type: ${match['match_type'] ?? 'Cricket'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Venue: ${match['venue'] ?? 'TBA'}',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 10),
            const Text(
              'VIEW MATCH DETAILS  →',
              style: TextStyle(color: gold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// MATCH DETAILS

class MatchDetailsPage extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH DETAILS'),
        backgroundColor: bg,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            match['match_title'] ?? 'Cricket Match',
            style: const TextStyle(
              color: gold,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DetailRow('Tournament', match['tournament']),
          DetailRow('Match Type', match['match_type']),
          DetailRow('Venue', match['venue']),
          DetailRow('Status', match['status']),
          DetailRow('Result', match['result']),
          const SectionTitle('SCORECARD'),
          const EmptyCard(
            message: 'Scorecard data will appear here when available.',
          ),
          const SizedBox(height: 15),
          const Text(
            'Live scores require a licensed cricket data API.',
            style: TextStyle(color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const DetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Flexible(
            child: Text(
              value?.toString() ?? 'Not available',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// TEAMS PAGE

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AppHeader('CRICKET TEAMS'),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase.from('teams').select().order('name'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: gold),
              );
            }

            if (snapshot.hasError) {
              return ErrorCard(message: snapshot.error.toString());
            }

            final teams = snapshot.data ?? [];

            if (teams.isEmpty) {
              return const EmptyCard(
                message: 'No teams added yet.',
              );
            }

            return Column(
              children: teams.map((team) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF263B56),
                        child: Icon(Icons.shield, color: gold),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team['name'] ?? 'Unknown Team',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              team['country'] ?? '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        team['short_name'] ?? '',
                        style: const TextStyle(color: gold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// NEWS PAGE

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AppHeader('CRICKET NEWS'),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase
              .from('news')
              .select()
              .eq('published', true)
              .order('created_at', ascending: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: gold),
              );
            }

            if (snapshot.hasError) {
              return ErrorCard(message: snapshot.error.toString());
            }

            final news = snapshot.data ?? [];

            if (news.isEmpty) {
              return const EmptyCard(
                message: 'No published cricket news yet.',
              );
            }

            return Column(
              children: news.map((item) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['category'] ?? 'CRICKET NEWS',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// STATS PAGE

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AppHeader('CRICKET STATS'),
        const SectionTitle('TOURNAMENT POINTS TABLE'),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase.from('points_table').select(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: gold),
              );
            }

            if (snapshot.hasError) {
              return ErrorCard(message: snapshot.error.toString());
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return const EmptyCard(
                message: 'No tournament standings available.',
              );
            }

            return Column(
              children: records.map((row) {
                return ListTile(
                  title: Text(row['tournament'] ?? 'Tournament'),
                  subtitle: Text(
                    'Played: ${row['played']}  Won: ${row['won']}',
                  ),
                  trailing: Text(
                    '${row['points']} PTS',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// FEATURE CARD

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const FeatureCard(this.icon, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF29384D)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: gold, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// EMPTY AND ERROR STATES

class EmptyCard extends StatelessWidget {
  final String message;

  const EmptyCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String message;

  const ErrorCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Database Error:\n$message',
        style: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }
}
