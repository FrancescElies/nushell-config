# Official website: https://www.radare.org/n/
# Book: https://book.rada.re/
# https://monosource.gitbooks.io/radare2-explorations/content/introduction.html

# https://github.com/capstone-engine/capstone?tab=readme-ov-file

# radare2
export alias r2 = radare2

# retrieves basic binary info (imports, strings, libraries, relocs, entry-point, symbols)
# https://book.rada.re/tools/rabin2
export def "rabin2 quick" [file: path, ] {
  let folder = ($file | path basename)
  mkdir $folder
  cd $folder
  let file = ($file | path expand) 

  rabin2 -I  $file | save -f file-type.txt
  rabin2 -i  $file | save -f imports.txt
  rabin2 -E  $file | save -f exports.txt
  rabin2 -s  $file | save -f symbols.txt
  rabin2 -l  $file | save -f libraries.txt
  rabin2 -S  $file | save -f sections.txt
  rabin2 -z $file | save -f strings-data-section.txt
  rabin2 -zzz $file | save -f strings-raw.txt
  rabin2 -R  $file | save -f relocs.txt
  rabin2 -e  $file | save -f entry_point.txt

  echo "see output:"
  ls $folder
}
