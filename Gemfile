source "https://rubygems.org"

gem "metanorma-cli", github: "metanorma/metanorma-cli", branch: "main"
# The CLI aggregate resolves its flavor deps from rubygems, where the
# newest STABLE releases still subclass the removed Relaton::Render::Parse
# (relaton-render#148) and crash the boot. The prerelease floors pair the
# bundle with the shim-free generation instead.
gem "metanorma-ietf", ">= 3.7.12.pre.alpha.1"
gem "metanorma-bipm", ">= 2.9.1.pre.alpha.1"
gem "metanorma-iho", ">= 1.4.1.pre.alpha.1"
gem "metanorma-itu", ">= 2.9.3.pre.alpha.1"
gem "metanorma-ogc", ">= 2.10.1.pre.alpha.1"
gem "metanorma-ieee", ">= 1.7.1.pre.alpha.1"
gem "debug"
gem "sassc-embedded"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "metanorma", github: "metanorma/metanorma", branch: "main"
gem "metanorma-taste", github: "metanorma/metanorma-taste", branch: "main"
gem "metanorma-utils", github: "metanorma/metanorma-utils", branch: "main"

gem "moxml", github: "lutaml/moxml", branch: "main"
gem "relaton-cli", "~> 3.0"
