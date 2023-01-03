#!/bin/bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# you can pass the versions (of Joomla) to this file for the initial/re-build
versions=("$@")
if [ ${#versions[@]} -eq 0 ]; then
  # get the folders from the current root directory of the project as the versions
  # if no versions where passed to the file
  # this is the standard (2021) way fo doing this
  # see (https://github.com/docker-library/php/blob/master/versions.sh#L38)
  versions=(*/)
  # was assume the folders to be correct
  # and will serve as the rule
  # so the json is build from that
  json='{}'
else
  # with the initial/re-build the versions.json is manually set
  json="$(<versions.json)"
fi
# always make sure the folder / slash is removed
versions=("${versions[@]%/}")

# we use the versions help until the API is improved (with local overriding options)
if [ -f .versions-helper.json ]; then
   versionsHelper="$(<.versions-helper.json)"
elif [ -f versions-helper.json ]; then
   versionsHelper="$(<versions-helper.json)"
else
  echo "versions-helper.json file not found!"
  exit 1
fi

# now we loop over the (Joomla) versions
for version in "${versions[@]}"; do
  export version
  doc='{}'

  # lets get the full version
  fullVersion=$(echo $versionsHelper | jq -r '.["'"${version}"'"].branch')
  export fullVersion

  # lets see if we have a tar URL
  LIBXL_VER=$(echo $versionsHelper | jq -r '.["'"${version}"'"].libxlVersion')

  # when not found we load sha512 from API
  if [ "${LIBXL_VER}" != 'null' ]; then
    # get the url version
    #urlVersion=$(echo $fullVersion | sed -e 's/\./-/g')

    DISTRO=lin
    libxl_file=libxl-${DISTRO}-${LIBXL_VER}
    libxlPackageUrl="http://www.libxl.com/download/${libxl_file}.tar.gz"

#    excelPackageUrl="https://github.com/iliaal/php_excel.git"
    excelPackageUrl="https://github.com/Jan-E/php_excel.git"
    export libxlPackageUrl
    export excelPackageUrl
  fi

  # set the hash to the JSON
  if [ -n "$libxlPackageUrl" ] && [ -n "$excelPackageUrl" ]; then
    doc="$(jq <<<"$doc" -c '.excel_url = env.excelPackageUrl')"
    doc="$(jq <<<"$doc" -c '.libxl_url = env.libxlPackageUrl')"
  fi

  # get the default php version
  defaultPHP=$(echo $versionsHelper | jq -r '.[env.version].php')
  # get the PHP versions
  phpVersions=$(echo $versionsHelper | jq -r '.[env.version].phpVersions | keys[]' | jq -R -s -c '. / "\n" - [""]')
  # get the default variant
  defaultVariant=$(echo $versionsHelper | jq -r '.[env.version].variant')
  # get the variants
  variants=$(echo $versionsHelper | jq -r '.[env.version].variants')
  # get the aliases
  aliases=$(echo $versionsHelper | jq -r '.[env.version].aliases')
  # get libxlVersion version
  libxlVersion=$(echo $versionsHelper | jq -r '.[env.version].libxlVersion')

  # echo some version details
  echo "### php_excel $version.x details"
  echo "# Version => $fullVersion"
  echo "# PHP     => $defaultPHP"
  echo "# excel_url  => $excelPackageUrl"

  # build this fullVersion matrix
  # and add it to the JSON
  json="$(
    jq <<<"$json" -c \
      --argjson doc "$doc" \
      --argjson phpVersions "$phpVersions" \
      --argjson aliases "$aliases" \
      --argjson variants "$variants" \
      --arg defaultPHP "$defaultPHP" \
      --arg libxlVersion "$libxlVersion" \
      --arg defaultVariant "$defaultVariant" '
			.[env.version] = {
				branch: env.fullVersion,
				php: $defaultPHP,
        phpVersions: $phpVersions,
				variant: $defaultVariant,
				variants: $variants,
				libxlVersion: $libxlVersion,
				aliases: $aliases,
			} + $doc
		'
  )"
done

# store the JSON to the file system
jq <<<"$json" -S . >versions.json
