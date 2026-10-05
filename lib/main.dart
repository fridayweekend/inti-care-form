import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const IntiCareApp());

const primary = Color(0xFFBD1830);
const ink = Color(0xFF202C3D);
const muted = Color(0xFF647084);
const accent = Color(0xFF237564);
const fieldFill = Color(0xFFF8F9FC);

class IntiCareApp extends StatelessWidget {
  const IntiCareApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'INTI Care | Student services',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        error: const Color(0xFFB3261E),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.all(17),
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE1E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    ),
    home: const CampusRequestPage(),
  );
}

// Shared, deterministic validators are used by the form and its boundary tests.
class CampusValidators {
  static String? name(String? value) =>
      (value ?? '')
              .trim()
              .split(RegExp(r'\s+'))
              .where((s) => s.isNotEmpty)
              .length <
          2
      ? 'Enter your full name, with at least two words.'
      : null;
  static String? studentId(String? value) =>
      RegExp(r'^INTI-\d{7}$').hasMatch((value ?? '').trim())
      ? null
      : 'Use INTI- followed by 7 digits, e.g. INTI-2026001.';
  static String? email(String? value) =>
      RegExp(
        r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$',
      ).hasMatch((value ?? '').trim())
      ? null
      : 'Enter a complete email address, e.g. alex@student.example.edu.';
  static String? phone(String? value, {bool required = false}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return required ? 'Add a phone number when choosing a phone call.' : null;
    }
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(text)
        ? null
        : 'Use 9–15 digits, with an optional leading +.';
  }

  static String? subject(String? value) => (value ?? '').trim().length < 5
      ? 'Use at least 5 characters for your subject.'
      : null;
  static String? details(String? value) {
    final length = (value ?? '').trim().length;
    return length < 20 || length > 500
        ? 'Describe your request in 20–500 characters.'
        : null;
  }

  static String? date(DateTime? value, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    if (value == null) return 'Choose a preferred response date.';
    return DateUtils.dateOnly(value).isBefore(today)
        ? 'Choose today or a future date.'
        : null;
  }
}

class CampusRequestPage extends StatefulWidget {
  const CampusRequestPage({super.key});
  @override
  State<CampusRequestPage> createState() => _CampusRequestPageState();
}

class _CampusRequestPageState extends State<CampusRequestPage> {
  // One persistent key owns validation, onSaved callbacks and FormState.reset.
  final formKey = GlobalKey<FormState>();
  final scroll = ScrollController();
  final controllers = {
    for (final key in [
      'name',
      'id',
      'email',
      'phone',
      'subject',
      'details',
      'location',
    ])
      key: TextEditingController(),
  };
  final anchors = List.generate(4, (_) => GlobalKey());
  final dateKey = GlobalKey<FormFieldState<DateTime>>();
  final declarationKey = GlobalKey<FormFieldState<bool>>();
  String? category, urgency, contact;
  DateTime? date;
  bool declaration = false;
  bool submitted = false;
  int formVersion = 0;
  final saved = <String, String>{};
  static const categories = [
    'IT & Wi-Fi',
    'Facilities & maintenance',
    'Library services',
    'Accommodation',
    'Academic advice',
    'Student activities',
  ];
  bool get needsLocation =>
      category == 'Facilities & maintenance' || category == 'Accommodation';

  @override
  void dispose() {
    // Controllers and scrolling resources live exactly as long as this page.
    for (final controller in controllers.values) {
      controller.dispose();
    }
    scroll.dispose();
    super.dispose();
  }

  void message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  String displayDate(DateTime value) =>
      MaterialLocalizations.of(context).formatFullDate(value);
  void jumpTo(int index) {
    final target = anchors[index].currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        alignment: 0.05,
      );
    }
  }

  // Reset both registered form fields and state held outside FormField.
  void reset({bool feedback = true}) {
    FocusScope.of(context).unfocus();
    formKey.currentState?.reset();
    for (final controller in controllers.values) {
      controller.clear();
    }
    setState(() {
      category = urgency = contact = null;
      date = null;
      declaration = false;
      submitted = false;
      saved.clear();
      formVersion++;
    });
    scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    if (feedback) message('Form cleared. You can start a new request.');
  }

  Future<void> pickDate(FormFieldState<DateTime> state) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: date != null && !date!.isBefore(today) ? date! : today,
      firstDate: today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
      helpText: 'Preferred response date',
    );
    if (!mounted || selected == null) return;
    setState(() => date = selected);
    state.didChange(selected);
  }

  int firstInvalidSection() {
    if (CampusValidators.name(controllers['name']!.text) != null ||
        CampusValidators.studentId(controllers['id']!.text) != null ||
        CampusValidators.email(controllers['email']!.text) != null ||
        CampusValidators.phone(
              controllers['phone']!.text,
              required: contact == 'Phone call',
            ) !=
            null) {
      return 0;
    }
    if (category == null ||
        CampusValidators.subject(controllers['subject']!.text) != null ||
        CampusValidators.details(controllers['details']!.text) != null ||
        urgency == null ||
        (needsLocation && controllers['location']!.text.trim().isEmpty)) {
      return 1;
    }
    if (contact == null || CampusValidators.date(date) != null) return 2;
    return 3;
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    setState(() => submitted = true);
    // Save is deliberately unreachable until every validator has passed.
    if (!formKey.currentState!.validate()) {
      jumpTo(firstInvalidSection());
      message('Check the highlighted fields. Your entries have been kept.');
      return;
    }
    saved.clear();
    formKey.currentState!.save();
    final reference =
        'CARE-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final newRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: accent, size: 42),
        title: const Text('Your request is ready'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Demo submission complete. No request has been sent to the university.',
                ),
                const SizedBox(height: 16),
                Text(
                  reference,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry
                    in saved.entries.toList()..sort((a, b) {
                      const order = [
                        'Full name',
                        'Student ID',
                        'Campus email',
                        'Phone number',
                        'Phone number (optional)',
                        'Campus service',
                        'Building / room',
                        'Request subject',
                        'Request details',
                        'Urgency',
                        'Preferred contact',
                        'Preferred response date',
                        'Declaration',
                      ];
                      return order
                          .indexOf(a.key)
                          .compareTo(order.indexOf(b.key));
                    }))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.key}\n',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: entry.value),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Back to form'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('New request'),
          ),
        ],
      ),
    );
    if (mounted && newRequest == true) reset();
  }

  Widget textField(
    String id,
    String label,
    String hint,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? keyboard,
    int? maxLength,
    int lines = 1,
    String? helper,
  }) => CampusTextField(
    key: ValueKey(id),
    controller: controllers[id]!,
    label: label,
    hint: hint,
    icon: icon,
    validator: validator,
    keyboard: keyboard,
    maxLength: maxLength,
    lines: lines,
    helper: helper,
    onSaved: (value) => saved[label.replaceAll(' *', '')] =
        (value ?? '').trim().isEmpty ? 'Not provided' : value!.trim(),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 76,
      title: Row(
        children: [
          Image.asset('assets/logo.jpg', width: 62, semanticLabel: 'INTI'),
          const SizedBox(width: 16),
          Container(width: 1, height: 26, color: const Color(0xFFDCE1E9)),
          const SizedBox(width: 16),
          const Text(
            'Care',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'About this form',
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('A little help, closer to you'),
              content: const Text(
                'This student prototype demonstrates a validated campus request form. All submissions are simulated. Entries stay on screen until Reset or refresh; nothing is stored or sent.\n\nExample student ID: INTI-2026001. Use your campus email format. For urgent safety concerns, contact your campus emergency service directly.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: LayoutBuilder(
              builder: (context, bounds) {
                final wide = bounds.maxWidth >= 900;
                final form = Form(
                  key: formKey,
                  autovalidateMode: submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    key: ValueKey(formVersion),
                    children: [
                      section(
                        0,
                        '01',
                        'Student details',
                        'Let us know who we are helping.',
                        Icons.person_outline_rounded,
                        [
                          pair(
                            textField(
                              'name',
                              'Full name *',
                              'e.g. Alex Tan',
                              Icons.person_outline,
                              CampusValidators.name,
                              maxLength: 80,
                            ),
                            textField(
                              'id',
                              'Student ID *',
                              'INTI-2026001',
                              Icons.badge_outlined,
                              CampusValidators.studentId,
                              maxLength: 12,
                            ),
                          ),
                          pair(
                            textField(
                              'email',
                              'Campus email *',
                              'alex@student.example.edu',
                              Icons.alternate_email,
                              CampusValidators.email,
                              keyboard: TextInputType.emailAddress,
                              maxLength: 120,
                            ),
                            textField(
                              'phone',
                              contact == 'Phone call'
                                  ? 'Phone number *'
                                  : 'Phone number (optional)',
                              '+60123456789',
                              Icons.phone_outlined,
                              (v) => CampusValidators.phone(
                                v,
                                required: contact == 'Phone call',
                              ),
                              keyboard: TextInputType.phone,
                              maxLength: 16,
                            ),
                          ),
                        ],
                      ),
                      section(
                        1,
                        '02',
                        'How can we help?',
                        'Choose a service and tell us what you need.',
                        Icons.chat_bubble_outline_rounded,
                        [
                          DropdownButtonFormField<String>(
                            key: const ValueKey('category'),
                            isExpanded: true,
                            initialValue: category,
                            decoration: const InputDecoration(
                              labelText: 'Campus service *',
                              prefixIcon: Icon(Icons.grid_view_rounded),
                              hintText: 'Select a service',
                            ),
                            items: categories
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            validator: (value) => value == null
                                ? 'Select the campus team you need.'
                                : null,
                            onSaved: (value) =>
                                saved['Campus service'] = value!,
                            onChanged: (value) => setState(() {
                              category = value;
                              if (!needsLocation) {
                                controllers['location']!.clear();
                              }
                            }),
                          ),
                          const SizedBox(height: 22),
                          // Conditional customization: only location-based teams need a room.
                          if (needsLocation)
                            textField(
                              'location',
                              'Building / room *',
                              'e.g. Block B, room 2-14',
                              Icons.location_on_outlined,
                              (v) => (v ?? '').trim().isEmpty
                                  ? 'Tell us which building or room needs attention.'
                                  : null,
                              maxLength: 80,
                            ),
                          textField(
                            'subject',
                            'Request subject *',
                            'Give your request a short title',
                            Icons.edit_note_rounded,
                            CampusValidators.subject,
                            maxLength: 80,
                          ),
                          // Flutter's built-in counter stays in sync with edits and reset.
                          textField(
                            'details',
                            'Request details *',
                            'What happened? How can our campus team help?',
                            Icons.notes_rounded,
                            CampusValidators.details,
                            maxLength: 500,
                            lines: 4,
                            helper:
                                '20–500 characters. Include useful details, not passwords.',
                          ),
                          const SizedBox(height: 4),
                          choice(
                            'Urgency *',
                            ['Low', 'Normal', 'High'],
                            urgency,
                            (v) => setState(() => urgency = v),
                            'Choose how urgent your request is.',
                            'Urgency',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'High urgency is a priority preference, not an emergency channel.',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                      section(
                        2,
                        '03',
                        'Stay in touch',
                        'Tell us how and when you prefer a response.',
                        Icons.schedule_rounded,
                        [
                          choice(
                            'Preferred contact *',
                            ['Email', 'Phone call'],
                            contact,
                            (v) => setState(() => contact = v),
                            'Choose email or a phone call.',
                            'Preferred contact',
                          ),
                          const SizedBox(height: 22),
                          FormField<DateTime>(
                            key: dateKey,
                            validator: CampusValidators.date,
                            onSaved: (value) =>
                                saved['Preferred response date'] = displayDate(
                                  value!,
                                ),
                            builder: (state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => pickDate(state),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Preferred response date *',
                                      prefixIcon: const Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                      suffixIcon: const Icon(Icons.expand_more),
                                      errorText: state.errorText,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        date == null
                                            ? 'Choose a date'
                                            : displayDate(date!),
                                        style: TextStyle(
                                          color: date == null ? muted : ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, left: 12),
                                  child: Text(
                                    'Today or later. This is a preference, not a confirmed booking.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      section(
                        3,
                        '04',
                        'Check and send',
                        'One final check before your request is submitted.',
                        Icons.task_alt_rounded,
                        [
                          FormField<bool>(
                            key: declarationKey,
                            initialValue: false,
                            validator: (value) => value == true
                                ? null
                                : 'Please confirm the declaration before sending.',
                            onSaved: (value) =>
                                saved['Declaration'] = 'Confirmed',
                            builder: (state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: declaration,
                                  title: const Text(
                                    'I confirm that the information above is accurate and may be used to respond to this request.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  onChanged: (value) {
                                    setState(
                                      () => declaration = value ?? false,
                                    );
                                    state.didChange(declaration);
                                  },
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      top: 6,
                                    ),
                                    child: Text(
                                      state.errorText!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: submit,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Send request'),
                              ),
                              OutlinedButton.icon(
                                onPressed: reset,
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: const Text('Reset form'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Student project · Demo submissions only · Entries clear on refresh',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STUDENT SERVICES / NEW REQUEST',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.8,
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A little help.\nA better campus day.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'From Wi-Fi worries to campus life, start your request here.\nFields marked * are required.',
                      style: TextStyle(color: muted, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 280, child: sidebar()),
                          const SizedBox(width: 28),
                          Expanded(child: form),
                        ],
                      )
                    else
                      form,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  Widget sidebar() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFFFBCC5),
              size: 34,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your campus.\nYour support team.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A single place to ask for a hand and get your day back on track.',
              style: TextStyle(color: Color(0xFFCED6E2), height: 1.6),
            ),
            const SizedBox(height: 22),
            for (final item in [
              (0, 'Student details'),
              (1, 'Your request'),
              (2, 'Contact preferences'),
              (3, 'Check and send'),
            ])
              TextButton(
                onPressed: () => jumpTo(item.$1),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  alignment: Alignment.centerLeft,
                ),
                child: Text('0${item.$1 + 1}   ${item.$2}'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/academic_block.jpg',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          semanticLabel: 'INTI campus academic block',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Made for student life.\nAn unofficial INTI student prototype.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.6),
        ),
      ),
    ],
  );

  Widget section(
    int index,
    String number,
    String title,
    String subtitle,
    IconData icon,
    List<Widget> children,
  ) => Container(
    key: anchors[index],
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE3E7EF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x04202C3D),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDF0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(number, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 26),
        ...children,
      ],
    ),
  );

  // Responsive rows become a single column on narrow screens or large text.
  Widget pair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, bounds) =>
        bounds.maxWidth >= 570 &&
            MediaQuery.textScalerOf(context).scale(14) < 20
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: second),
            ],
          )
        : Column(children: [first, second]),
  );

  Widget choice(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String> onChanged,
    String error,
    String savedLabel,
  ) => FormField<String>(
    initialValue: value,
    validator: (value) => value == null ? error : null,
    onSaved: (value) => saved[savedLabel] = value!,
    builder: (state) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: value == option,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  onSelected: (_) {
                    onChanged(option);
                    state.didChange(option);
                  },
                ),
              )
              .toList(),
        ),
        if (state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    ),
  );
}

// Reusable field keeps labels, spacing, keyboard behavior and validation consistent.
class CampusTextField extends StatelessWidget {
  const CampusTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.onSaved,
    this.keyboard,
    this.maxLength,
    this.lines = 1,
    this.helper,
  });
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final String? Function(String?) validator;
  final FormFieldSetter<String> onSaved;
  final TextInputType? keyboard;
  final int? maxLength;
  final int lines;
  final String? helper;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: lines > 1 ? TextInputType.multiline : keyboard,
      textInputAction: lines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      textCapitalization: keyboard == null
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      minLines: lines,
      maxLines: lines > 1 ? 7 : 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 21),
        helperText: helper,
        counterText: lines > 1 ? null : '',
      ),
    ),
  );
}
