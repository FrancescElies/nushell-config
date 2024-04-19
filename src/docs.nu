export def download-python-docs [py_version: string] {
    let zipfile = 'python-' + $py_version + '-docs-text.zip'
    print $zipfile
    if not ($zipfile | path exists) { 
      http get $'https://docs.python.org/3/archives/($zipfile)' | save $zipfile
      extract $zipfile
    }

    let zipfile = 'python-' + $py_version + '-docs-html.zip'
    if not ($zipfile | path exists) { 
      http get $'https://docs.python.org/3/archives/($zipfile)' | save $zipfile
      extract $zipfile
    }
    
}

export def 'docs python' [] {
  mkdir '~/src/python-docs' 
  cd '~/src/python-docs' 
  let py_version = '3.12.0'
  download-python-docs $py_version
  br "~/src/python-docs"
}


