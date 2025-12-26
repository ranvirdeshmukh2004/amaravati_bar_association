import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database_provider.dart';
import '../../database/app_database.dart';

class MemberSearchAutocomplete extends ConsumerWidget {
  final Function(Member) onMemberSelected;

  const MemberSearchAutocomplete({super.key, required this.onMemberSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Autocomplete<Member>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Member>.empty();
        }
        final db = ref.read(databaseProvider);
        return await db.membersDao.searchMembers(
          textEditingValue.text,
          onlyActive: true,
        );
      },
      displayStringForOption: (Member option) =>
          '${option.firstName} ${option.surname} - ${option.registrationNumber}',
      onSelected: onMemberSelected,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: const InputDecoration(
            labelText: 'Search Member *',
            hintText: 'Name, Mobile, or Reg No',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            helperText: 'Select a member to proceed',
            filled: true,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
             elevation: 4.0,
             color: Theme.of(context).cardColor,
             child: SizedBox(
               width: 400,
               child: ListView.builder(
                 padding: const EdgeInsets.all(8.0),
                 shrinkWrap: true,
                 itemCount: options.length,
                 itemBuilder: (BuildContext context, int index) {
                   final Member option = options.elementAt(index);
                   return ListTile(
                     leading: ClipRRect(
                       borderRadius: BorderRadius.circular(4),
                       child: option.profilePhotoPath != null
                           ? Image.file(
                               File(option.profilePhotoPath!),
                               width: 40,
                               height: 40,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) { 
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  );
                               }
                             )
                           : Container(
                               width: 40,
                               height: 40,
                               color: Theme.of(context).colorScheme.surfaceContainerHighest,
                               child: const Icon(Icons.person, color: Colors.grey),
                             ),
                     ),
                     title: Text('${option.firstName} ${option.surname}'),
                     subtitle: Text('Reg: ${option.registrationNumber}\nMob: ${option.mobileNumber}'),
                     isThreeLine: true,
                     onTap: () {
                       onSelected(option);
                     },
                   );
                 },
               ),
             ),
           ),
        );
      },
    );
  }
}
