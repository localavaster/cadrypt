import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/runes.dart';
import '../../../global/cipher.dart';
import '../../../widgets/container_header.dart';
import '../../../widgets/container_item.dart';

class StatisticsContainer extends StatelessWidget {
  const StatisticsContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4125,
        child: Material(
          elevation: 2,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              const ContainerHeader(
                name: 'Statistics',
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Cryptanalysis'),
                    ),
                    ContainerItem(
                      name: 'IoC',
                      value: GetIt.I<Cipher>().get_index_of_coincidence().toStringAsFixed(6),
                    ),
                    ContainerItem(
                      name: 'Entropy',
                      value: GetIt.I<Cipher>().get_entropy().toStringAsFixed(6),
                    ),
                    ContainerItem(name: 'Bigram Ratio', value: GetIt.I<Cipher>().gram_ratio(2).toStringAsFixed(4)),
                    ContainerItem(name: 'Bigram Peak', value: GetIt.I<Cipher>().get_gram_ratio_peak(2).toString()),
                    ContainerItem(name: 'Bigram Low', value: GetIt.I<Cipher>().get_gram_ratio_low(2).toString()),
                    ContainerItem(name: 'Trigram Ratio', value: GetIt.I<Cipher>().gram_ratio(3).toStringAsFixed(4)),
                    ContainerItem(name: 'Same-GP Ratio', value: GetIt.I<Cipher>().get_gp_sum_ratio().toStringAsFixed(4)),
                    ContainerItem(name: 'Avg. Letter Distance', value: GetIt.I<Cipher>().get_average_letter_distance().toStringAsFixed(1)),
                    ContainerItem(name: 'Avg. Rune Repeat Dist.', value: GetIt.I<Cipher>().get_average_distance_until_letter_repeat().toStringAsFixed(1)),
                    ContainerItem(name: 'Avg. Dbl Rune Repeat Dist.', value: GetIt.I<Cipher>().get_average_distance_until_double_rune_repeat().toStringAsFixed(1)),
                    ContainerItem(name: 'Avg. X Repeat Dist.', value: GetIt.I<Cipher>().get_average_distance_until_rune_repeat('ᛉ').toStringAsFixed(1)),
                    ContainerItem(name: 'Avg. F Repeat Dist.', value: GetIt.I<Cipher>().get_average_distance_until_rune_repeat(runes.first).toStringAsFixed(1)),
                    ContainerItem(name: 'Unused Runes', value: GetIt.I<Cipher>().get_characters_not_used().length.toString()),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Dimensions'),
                    ),
                    ContainerItem(name: 'Length', value: GetIt.I<Cipher>().flat_cipher_length.toString()),
                    ContainerItem(name: 'Width', value: GetIt.I<Cipher>().get_longest_row().toString()),
                    ContainerItem(name: 'Height', value: GetIt.I<Cipher>().raw_cipher.length.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
