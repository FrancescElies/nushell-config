use ~/src/nushell-config/src/rust.nu *

def download-python-docs [py_version: string] {
    let zipfile = 'python-' + $py_version + '-docs-text.zip'
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

export def 'docs vim' [] {
  if not ("~/src/oss/vim-galore" | path exists) {
    cd ~/src/oss
    git clone https://github.com/mhinz/vim-galore
  }
  cd ~/src/oss/vim-galore
  nvim *.md
}

export def 'docs python' [] {
  let dir = ("~/src/oss/python-docs" | path expand)
  mkdir $dir
  cd $dir
  let py_version = '3.12.0'
  download-python-docs $py_version
  ^broot $dir
}

export def "docs js" [] {
  if not ("~/src/oss/You-Dont-Know-JS" | path exists) {
    cd ~/src/oss
    git clone https://github.com/francescelies/You-Dont-Know-JS
  }
  cd ~/src/oss/You-Dont-Know-JS
  just open
}
export alias you-dont-know-js = docs js

export def "docs rust" [] {
  rustup doc
  rust links
}
