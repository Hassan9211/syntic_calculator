import 'package:flutter/material.dart';
import 'package:syntic_calculator/app_colors.dart';
import 'package:syntic_calculator/routes/route_paths.dart';
import 'package:syntic_calculator/storage/calculation_history_storage.dart';
import 'package:syntic_calculator/widgets/bottom_buttons.dart';
import 'package:syntic_calculator/widgets/header.dart';

/// Yeh save hui calculations ki history screen hai.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Screen par render hone wali grouped history state yahin rakhi jati hai.
  List<_HistorySection> _sections = const <_HistorySection>[];
  bool _isLoading = true;
  bool _isSwipeDeleteEnabled = false;

  @override
  void initState() {
    super.initState();
    _refreshSections();
  }

  /// Local storage se items la kar unhein date ke hisab se sections me group karta hai.
  Future<List<_HistorySection>> _loadSections() async {
    final items = await CalculationHistoryStorage.load();
    final sections = <_HistorySection>[];

    for (final item in items) {
      final title = _sectionTitle(item.createdAt);

      if (sections.isEmpty || sections.last.title != title) {
        sections.add(_HistorySection(title: title, entries: [item]));
      } else {
        sections.last.entries.add(item);
      }
    }

    return sections;
  }

  /// Latest saved history ko state me la kar UI refresh karta hai.
  Future<void> _refreshSections() async {
    final sections = await _loadSections();

    if (!mounted) {
      return;
    }

    setState(() {
      _sections = sections;
      _isLoading = false;
      if (_sections.isEmpty) {
        _isSwipeDeleteEnabled = false;
      }
    });
  }

  /// User jab clear button dabaye to puri history remove kar deta hai.
  Future<void> _clearHistory() async {
    await CalculationHistoryStorage.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _sections = const <_HistorySection>[];
      _isLoading = false;
      _isSwipeDeleteEnabled = false;
    });
  }

  /// Footer pill par tap se swipe mode on/off hota hai.
  void _toggleSwipeDelete() {
    if (_sections.isEmpty) {
      return;
    }

    final nextValue = !_isSwipeDeleteEnabled;
    setState(() {
      _isSwipeDeleteEnabled = nextValue;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            nextValue
                ? 'Swipe left on any history card to delete it.'
                : 'Swipe delete turned off.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Swiped item ko UI aur storage dono se remove kar deta hai.
  Future<void> _deleteEntry(CalculationHistoryItem entry) async {
    setState(() {
      _sections = _sectionsAfterRemoving(entry);
      if (_sections.isEmpty) {
        _isSwipeDeleteEnabled = false;
      }
    });

    await CalculationHistoryStorage.delete(entry);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('History item deleted.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  /// Existing grouped list me se ek matching entry remove karke fresh sections banata hai.
  List<_HistorySection> _sectionsAfterRemoving(CalculationHistoryItem target) {
    final updatedSections = <_HistorySection>[];
    var removed = false;

    for (final section in _sections) {
      final updatedEntries = <CalculationHistoryItem>[];

      for (final entry in section.entries) {
        if (!removed && entry.matches(target)) {
          removed = true;
          continue;
        }

        updatedEntries.add(entry);
      }

      if (updatedEntries.isNotEmpty) {
        updatedSections.add(
          _HistorySection(title: section.title, entries: updatedEntries),
        );
      }
    }

    return updatedSections;
  }

  /// Har item ke liye TODAY, YESTERDAY ya full date heading banata hai.
  String _sectionTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(date.year, date.month, date.day);
    final dayOffset = today.difference(itemDay).inDays;

    if (dayOffset == 0) {
      return 'TODAY';
    }
    if (dayOffset == 1) {
      return 'YESTERDAY';
    }

    return '${_monthNames[itemDay.month - 1]} ${itemDay.day}, ${itemDay.year}'
        .toUpperCase();
  }

  /// Card ke neeche chhota time label dikhane ke liye format tayar karta hai.
  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return AppTabScaffold(
      currentRoute: AppRoutes.history,
      useTopSafeArea: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF17161F),
                    const Color(0xFF13131A),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.95),
                  radius: 1.35,
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              AppHeader(
                title: 'SYNTIC',
                useTopInset: true,
                topPadding: 14,
                horizontalPadding: 20,
                bottomPadding: 14,
                backgroundColor: const Color(
                  0xFF14131C,
                ).withValues(alpha: 0.76),
                titleColor: AppColors.textPrimary.withValues(alpha: 0.95),
                fontSize: 24,
                letterSpacing: 3,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPUTE LOG',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'History',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _HistoryPill(
                            label: 'CLEAR ALL',
                            icon: Icons.delete_sweep_outlined,
                            backgroundColor: AppColors.buttonSecondary.withValues(
                              alpha: 0.82,
                            ),
                            onTap: _clearHistory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (_isLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            }

                            if (_sections.isEmpty) {
                              return Column(
                                children: [
                                  const Expanded(child: _EmptyHistoryState()),
                                  const SizedBox(height: 18),
                                  _HistoryFooter(
                                    isSwipeDeleteEnabled: false,
                                    onTap: null,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      for (final section in _sections) ...[
                                        _SectionLabel(title: section.title),
                                        const SizedBox(height: 12),
                                        for (final entry in section.entries) ...[
                                          _HistoryEntryTile(
                                            entry: entry,
                                            timeLabel: _formatTime(
                                              entry.createdAt,
                                            ),
                                            isSwipeDeleteEnabled:
                                                _isSwipeDeleteEnabled,
                                            onDismissed:
                                                () => _deleteEntry(entry),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        const SizedBox(height: 12),
                                      ],
                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _HistoryFooter(
                                  isSwipeDeleteEnabled: _isSwipeDeleteEnabled,
                                  onTap: _toggleSwipeDelete,
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card ko swipe delete mode ke hisab se dismissible banata hai.
class _HistoryEntryTile extends StatelessWidget {
  const _HistoryEntryTile({
    required this.entry,
    required this.timeLabel,
    required this.isSwipeDeleteEnabled,
    required this.onDismissed,
  });

  final CalculationHistoryItem entry;
  final String timeLabel;
  final bool isSwipeDeleteEnabled;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(
        '${entry.createdAt.microsecondsSinceEpoch}-${entry.expression}-${entry.result}',
      ),
      direction: isSwipeDeleteEnabled
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDismissed(),
      background: const SizedBox.shrink(),
      secondaryBackground: const _DeleteHistoryBackground(),
      child: _HistoryCard(
        entry: entry,
        timeLabel: timeLabel,
        isSwipeDeleteEnabled: isSwipeDeleteEnabled,
      ),
    );
  }
}

/// Ek single save hui calculation ka card.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.timeLabel,
    this.isSwipeDeleteEnabled = false,
  });

  final CalculationHistoryItem entry;
  final String timeLabel;
  final bool isSwipeDeleteEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.buttonDark, AppColors.buttonSecondary],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.expression,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                isSwipeDeleteEnabled
                    ? Icons.swipe_left_alt_rounded
                    : Icons.history_toggle_off_rounded,
                size: 14,
                color: isSwipeDeleteEnabled
                    ? AppColors.primary.withValues(alpha: 0.88)
                    : AppColors.textSecondary.withValues(alpha: 0.65),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.result,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              timeLabel,
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.72),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upar right side ke actions jese "Clear All" ke liye reusable pill button.
class _HistoryPill extends StatelessWidget {
  const _HistoryPill({
    required this.label,
    required this.icon,
    this.onTap,
    this.foregroundColor,
    this.iconColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.fontSize = 11,
    this.iconSize = 14,
    this.letterSpacing = 0.9,
    this.fontWeight = FontWeight.w500,
    this.gradient,
    this.borderColor,
    this.boxShadow,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? foregroundColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final double letterSpacing;
  final FontWeight fontWeight;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final foreground =
        foregroundColor ?? AppColors.textPrimary.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null
                ? backgroundColor ??
                      AppColors.buttonSecondary.withValues(alpha: 0.82)
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor ?? AppColors.borderSubtle),
            boxShadow: boxShadow,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: iconColor ?? foreground),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yeh footer history ke neeche extra helper actions dikhata hai.
class _HistoryFooter extends StatelessWidget {
  const _HistoryFooter({
    required this.isSwipeDeleteEnabled,
    required this.onTap,
  });

  final bool isSwipeDeleteEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final footerText = AppColors.textSecondary.withValues(alpha: 0.82);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: _HistoryPill(
          label: 'SWIPE ITEMS TO DELETE',
          icon: Icons.backspace_outlined,
          onTap: onTap,
          foregroundColor: isSwipeDeleteEnabled
              ? AppColors.textPrimary.withValues(alpha: 0.96)
              : footerText.withValues(alpha: 0.76),
          iconColor: isSwipeDeleteEnabled
              ? AppColors.textPrimary
              : AppColors.primary.withValues(alpha: 0.88),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isSwipeDeleteEnabled
                  ? AppColors.primary.withValues(alpha: 0.82)
                  : const Color(0xFF3B3744).withValues(alpha: 0.95),
              isSwipeDeleteEnabled
                  ? AppColors.primaryDark.withValues(alpha: 0.64)
                  : AppColors.buttonSecondary.withValues(alpha: 0.98),
            ],
          ),
          borderColor: isSwipeDeleteEnabled
              ? AppColors.primary.withValues(alpha: 0.36)
              : AppColors.textSecondary.withValues(alpha: 0.11),
          boxShadow: [
            BoxShadow(
              color: isSwipeDeleteEnabled
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.16),
              blurRadius: isSwipeDeleteEnabled ? 22 : 16,
              offset: const Offset(0, 8),
            ),
          ],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          fontSize: 12.5,
          iconSize: 18,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// Swipe karte waqt delete affordance ko background me dikhata hai.
class _DeleteHistoryBackground extends StatelessWidget {
  const _DeleteHistoryBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF33131C), Color(0xFF6F2233)],
        ),
      ),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'DELETE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yeh empty state tab dikhai jati hai jab abhi tak koi calculation save na hui ho.
class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSubtle),
          color: AppColors.buttonSecondary.withValues(alpha: 0.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 16),
            const Text(
              'No calculations yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a calculation and it will be saved here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section heading jese TODAY ya YESTERDAY.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.55),
        fontSize: 11,
        letterSpacing: 1.4,
      ),
    );
  }
}

/// UI me grouped history section ko represent karta hai.
class _HistorySection {
  _HistorySection({required this.title, required this.entries});

  final String title;
  final List<CalculationHistoryItem> entries;
}

// Mahinon ke naam full date headings banane ke liye use hote hain.
const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
