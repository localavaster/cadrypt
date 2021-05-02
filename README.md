# cadrypt

A tool designed to assist with solving pages in the Liber Primus

![Alt Text](https://i.imgur.com/rSCeeIc.png)
 
# Current features
- Basic Solving using a console
- General cipher tools
- Full cribbing functionality, aswell as neat and maybe useful extension methods / filtering methods
- Sentence cribbing (Some sentences have been prime)
- Fully functioning cipher grid with multiple view modes (Regular, Flat, True to LP, 5x5, 3x3 and more)
- Load any page from the liber primus, aswell as solved ones.
- nGram visualization
- Frequency visualization
- Pattern analysis
- Statistics on a cipher (IoC, nGram Ratio, Entropy)
- Highlight areas of interest (double letters, small words, double rune letters, etc)
- Distance calculator
- Homophone analysis (by cribbing)
- Much more

# Road map
- Eventually this will become a full suite of tools designed for the Liber Primus and other things relating to it.

# Installing

**Prebuilt files**
Depending on your operating system
- Windows
Navigate to releases, download zip, extract, run.
- Mac OS
Navigate to releases, download zip, extract, run.
- Linux
TODO

NOTE: If you are experiencing a blank screen when you launch, Cadrypt takes a little bit of time to load a page when you first launch it, This is because of the "Repeated Similar nGrams" feature.

To fix this, you just have to wait a minute or two for the page to load in, you can also remove this feature entirely if you comment it out in global/cipher.dart

**Running it without prebuilt files**
Refer to https://flutter.dev/desktop#set-up and wiki, The build process should be similar for all 3 operating systems.

For any questions, refer to FAQ,

NOTE: You will have to copy over some folders and files to where cadrypt is located if you are doing a "flutter build" command, Otherwise if you are using "flutter run -d device_name --release", you do not have to copy over any files or folders

The files and folders you will have to copy are...
folders: assets, cribs, cicada_messages, solved_liberprimus_pages, liberprimus_pages, training_pages, english_words, english_statistics,
files: raw_oeis_sequences(? maybe), mod29_oeis_sequences, invalid_oeis_sequence_cache

# FAQ / I'm having an issue
Check out the wiki.

or contact me on discord avaster#5567

# Contributing
All contributions are welcome

If the codebase is confusing or you have questions about contributing, feel free to contact me on discord

avaster#5567

or create an Issue

# License
GPL v3
