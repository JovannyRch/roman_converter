import 'package:flutter/material.dart';

import '../../core/models/conversion_entry.dart';
import '../../core/theme/app_tokens.dart';
import '../converter/converter_service.dart';

class FavoritesSection extends StatelessWidget {
  const FavoritesSection({
    super.key,
    required this.items,
    required this.onTapItem,
    required this.onToggleFavorite,
  });

  final List<ConversionEntry> items;
  final ValueChanged<ConversionEntry> onTapItem;
  final ValueChanged<String> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Favoritos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.space2),
        ...items.take(5).map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTokens.borderSoft),
            ),
            child: ListTile(
              onTap: () => onTapItem(item),
              leading: const CircleAvatar(
                backgroundColor: AppTokens.warmMarble,
                child: Icon(Icons.temple_hindu_rounded, color: AppTokens.deepInk),
              ),
              title: Text('${item.input} -> ${item.output}'),
              subtitle: Text(
                item.direction == Direction.romanToArabic
                    ? 'Romano a arabe'
                    : 'Arabe a romano',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.star_rounded, color: AppTokens.mutedGold),
                onPressed: () => onToggleFavorite(item.id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
