import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final active = activeColor ?? colorScheme.primary;
    final inactive =
        inactiveColor ??
        (theme.brightness == Brightness.dark
            ? colorScheme.outline.withValues(alpha: 102)
            : colorScheme.outline.withValues(alpha: 153));
    final completed = completedColor ?? colorScheme.primary;

    return Column(
      children: [
        // Indicadores de pasos
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;
            final isLast = index == totalSteps - 1;

            return Expanded(
              child: Row(
                children: [
                  // Círculo del paso
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? completed
                                : isActive
                                ? active.withValues(alpha: 51)
                                : (theme.brightness == Brightness.dark
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.surfaceContainerLow),
                            border: Border.all(
                              color: isCompleted || isActive
                                  ? active
                                  : inactive,
                              width: 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: active.withValues(alpha: 102),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    color: colorScheme.onPrimary,
                                    size: 24,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: isActive
                                          ? active
                                          : (theme.brightness == Brightness.dark
                                                ? colorScheme.onSurfaceVariant
                                                : colorScheme.onSurface),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stepTitles[index],
                          style: textTheme.bodySmall?.copyWith(
                            color: isCompleted || isActive
                                ? active
                                : (theme.brightness == Brightness.dark
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface),
                            fontWeight: isCompleted || isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Línea conectora
                  if (!isLast)
                    Container(
                      width: 40,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isCompleted ? completed : inactive,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Barra de progreso
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: inactive,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (currentStep + 1) / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                color: active,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Texto de progreso
        Text(
          'Paso ${currentStep + 1} de $totalSteps',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
