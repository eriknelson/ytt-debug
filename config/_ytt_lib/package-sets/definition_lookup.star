#! config/_ytt_lib/package-sets/definition_lookup.star
#!   Looks up a package set definition by name and distro.
#!
#!   (this is a ytt-flavored Starlark file: https://carvel.dev/ytt/docs/v0.51.0/lang/#overview)

def package_sets(package_set_definitions, package_sets):
  return [
    lookup_package_set_def(package_set_definitions, 
      package_set.name, 
      package_set.distro) 
    for package_set in package_sets
  ]
end

def lookup_package_set_def(package_set_definitions, name, distro):
  package_sets = [
    package_set for package_set in package_set_definitions 
      if package_set.name == name and package_set.distro == distro
  ]
  if len(package_sets) == 0:
    fail("could not find package set definition for \"" + name + "\" on distro \"" + distro + "\" in data value \"package_set_definitions\"; is there a package-sets/definitions/" + name + "." + distro + ".yml file?")
  end  
  if len(package_sets) > 1:
    fail("found multiple package set definitions for \"" + name + "\" on distro \"" + distro + "\" in data value \"package_set_definitions\"; the package-sets/definitions ought to contain only one definition per package set per distro.")
  end  
  return package_sets[0]
end
