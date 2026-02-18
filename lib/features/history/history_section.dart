import 'package:flutter/material.dart';

import '../../core/models/conversion_entry.dart';
import '../../core/theme/app_tokens.dart';
import '../converter/converter_service.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({
    super.key,
    required this.items,
    required this.onTapItem,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onClear,
  });

  final List<ConversionEntry> items;
  final ValueChanged<ConversionEntry> onTapItem;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<String> onDelete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recientes', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            TextButton(onPressed: onClear, child: const Text('Limpiar')),
          ],
        ),
        const SizedBox(height: AppTokens.space2),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTapItem(item),
                child: Ink(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTokens.borderSoft),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.direction == Direction.romanToArabic
                                  ? 'Romano -> Arabe'
                                  : 'Arabe -> Romano',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              item.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppTokens.mutedGold,
                            ),
                            onPressed: () => onToggleFavorite(item.id),
                          ),
                        ],
                      ),
                      Text(
                        item.input,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        item.output,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTokens.laurel,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () => onDelete(item.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
