def download-python-docs [py_version: string] {
    let zipfile = 'python-' + $py_version + '-docs-text.zip'
    print $zipfile
    if not ($zipfile | path exists) { 
      print here
      http get $'https://docs.python.org/3/archives/($zipfile)' | save $zipfile
      extract $zipfile
    }
    print her3

    let zipfile = 'python-' + $py_version + '-docs-html.zip'
    if not ($zipfile | path exists) { 
      print here2
      http get $'https://docs.python.org/3/archives/($zipfile)' | save $zipfile
      extract $zipfile
    }
    print her4
    
}

export def 'docs python' [] {
  let dir = ("~/src/oss/python-docs" | path expand)
  mkdir $dir
  cd $dir
  let py_version = '3.12.0'
  download-python-docs $py_version
  ^broot $dir
}


