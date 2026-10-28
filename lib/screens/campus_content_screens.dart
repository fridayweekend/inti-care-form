import 'package:flutter/material.dart';
import '../data/campus_data.dart';
import '../models/campus_content.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final Set<String> bookmarkedIds = <String>{};

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: const PageStorageKey<String>('announcements'),
    padding: const EdgeInsets.all(12),
    itemCount: announcements.length,
    itemBuilder: (context, index) {
      final item = announcements[index];
      final saved = bookmarkedIds.contains(item.id);
      return Card(
        key: ValueKey(item.id),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(item.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Text('${item.category} • ${item.date}'),
              const SizedBox(height: 6),
              Text(item.preview),
            ],
          ),
          trailing: IconButton(
            key: ValueKey('bookmark-${item.id}'),
            tooltip: saved ? 'Remove bookmark' : 'Bookmark',
            isSelected: saved,
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => setState(() {
              saved
                  ? bookmarkedIds.remove(item.id)
                  : bookmarkedIds.add(item.id);
            }),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AnnouncementDetailScreen(item: item),
            ),
          ),
        ),
      );
    },
  );
}

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Announcement details')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('${item.category} • ${item.date}'),
            const SizedBox(height: 24),
            Text(item.detail, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            const Text('Fictional demonstration announcement.'),
          ],
        ),
      ),
    ),
  );
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700
          ? 4
          : constraints.maxWidth >= 420
          ? 3
          : 2;
      final tileWidth =
          (constraints.maxWidth - 32 - (columns - 1) * 12) / columns;
      // Measure labels at the actual text scale. Tiles grow vertically when
      // accessibility text needs more space, instead of clipping at a fixed ratio.
      final labelStyle = Theme.of(context).textTheme.titleMedium!;
      var labelHeight = 0.0;
      for (final service in services) {
        final painter = TextPainter(
          text: TextSpan(text: service.label, style: labelStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: (tileWidth - 24).clamp(1.0, double.infinity));
        if (painter.height > labelHeight) labelHeight = painter.height;
        painter.dispose();
      }
      final tileHeight = (labelHeight + 84).clamp(132.0, double.infinity);
      return GridView.builder(
        key: const PageStorageKey<String>('services'),
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: tileHeight,
        ),
        itemBuilder: (context, index) => ServiceTile(service: services[index]),
      );
    },
  );
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service});
  final CampusService service;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey('service-${service.id}'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ServiceDetailScreen(service: service),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              service.icon,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              service.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});
  final CampusService service;

  @override
  Widget build(BuildContext context) {
    final destination = service.detailDestination;
    return Scaffold(
      appBar: AppBar(title: Text(destination.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(service.icon, size: 48),
              const SizedBox(height: 16),
              Text(
                destination.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              Text(destination.location),
              const SizedBox(height: 16),
              Text(
                'Opening hours',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(destination.hours),
              const SizedBox(height: 24),
              const Text('Sample service information for demonstration only.'),
            ],
          ),
        ),
      ),
    );
  }
}
