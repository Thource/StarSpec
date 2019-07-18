# star_spec
StarSpec is a unit testing framework for Starfall - A lua based programming language in WireMod, a Garry's Mod addon.

## Installation
`SF` = `GMOD_INSTALL_LOCATION/data/starfall/`

While I recommend installing StarSpec at `SF/lib/`, it's ultimately your choice where you decide to install it.

```sh
cd SF
mkdir lib
cd lib
git clone https://github.com/Thource/star_spec
```

## Usage
Please use this as a template for your project's tests:
```lua
--@include lib/star_spec/star_spec.lua
require("lib/star_spec//star_spec.lua")

-- Include all of the classes that we're going to be testing
--@includedir classes
util.dodir("classes")

spec(function()
    -- Include the specs that we've written for our classes
    --@includedir specs
    util.dodir("specs")
end)
```

## Documentation
Coming soon
