# Machines
# Get azure devops machines having a certain capability
export def "az machines-usercapabilities" [
  has_capability: string = 'Python311',
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list 
     --pool-id 1 --include-capabilities -o $output 
     --query $"[?userCapabilities.($has_capability)!=null].{capabilities: userCapabilities, name: name}"
  )
}

# Get azure devops machines
export def "az machines" [
  --output (-o): string = 'yaml'  # json, jsonc, none, table, tsv, yaml, yamlc.
] {
  (  az pipelines agent list 
     --pool-id 1 --include-capabilities -o $output 
     --query "[*]"
  )
}

export def "build queue" [ definition_id: int = 42 ] {
  az pipelines build queue --open --branch (git rev-parse --abbrev-ref HEAD) --definition-id $definition_id
}


export def "build download" [
  build_id: int
] {
  az pipelines runs artifact download --artifact-name Installer --path ~/Downloads --run-id $build_id
}
