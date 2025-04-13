# https://github.com/NonlinearFruit/nu-gron/blob/master/gron.nu
export def main [--ungron --prefix:any=null object] {
  if ($ungron) {
    ungron $object
  } else {
    gron $prefix $object
  }
}

def gron [prefix object] {
  match ($object | describe) {
    $record if $record =~ ^record => (gron-record $prefix $object),
    $list if $list =~ ^list or $list =~ ^table => (gron-list $prefix $object),
    _ => (gron-primitive $prefix $object),
  }
}

export def ungron [object] {
  let root = $object | where key == null | get value | first
  $object
  | where key != null
  | where key !~ '[.]'
  | reduce --fold $root {|it acc|
    if ($acc | describe | $in =~ ^record) {
      $acc
      | merge (filter-object-and-ungron $it.key $it.value $object | { $it.key: $in })
    } else {
      $acc ++ (filter-object-and-ungron $it.key $it.value $object | [ $in ])
    }
  }
}

def gron-record [prefix record] {
  $record
  | items {|key value|
    if $prefix != null {
      $"($prefix).($key)"
    } else {
      $key
    }
    | main --prefix $in $value
  }
  | flatten
  | prepend { key: $prefix, value: {} }
}

def filter-object-and-ungron [prefix value object] {
  $object
  | where key != null
  | where ($it.key | str starts-with $"($prefix).")
  | if ($in | length) == 0 {
    $value
  } else {
    update key { str substring ($"($prefix)." | str length).. }
    | prepend { key: null, value: $value }
    | ungron $in
  }
}

def gron-list [prefix list] {
  $list
  | enumerate
  | each {|row|
    if $prefix != null {
      $"($prefix).[($row.index)]"
    } else {
      $"[($row.index)]"
    }
    | main --prefix $in $row.item
  }
  | flatten
  | prepend { key: $prefix, value: [] }
}

def gron-primitive [prefix primitive] {
  [ [key value]; [$prefix $primitive] ]
}
