#!/usr/bin/env bash
set -Eeuo pipefail

[ -f versions.json ] # run "versions.sh" first

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
  jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
  wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/5f0c26381fb7cc78b2d217d58007800bdcfbcfa1/scripts/jq-template.awk'
fi

# if no versions passed we load from versions.json
if [ "$#" -eq 0 ]; then
  versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
  eval "set -- $versions"
fi

# the warning message to not update the docker files directly
generated_warning() {
  cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

# set the maintainers of these docker images
maintainers="$( jq -cr '. | map(.firstname + " " + .lastname + " <" + .email + "> (@" + .github + ")") | join(", ")' maintainers.json)"
export maintainers

# loop over the version set above
for version; do
  export version
  # get this version details
  versionDetails="$(jq -r '.[env.version]' versions.json)"
  # get the PHP version
  phpVersions="$(echo "${versionDetails}" | jq -r '.phpVersions | map(@sh) | join(" ")')"
  eval "phpVersions=( $phpVersions )"
  # get the variants
  variants="$(echo "${versionDetails}" | jq -r '.variants | map(@sh) | join(" ")')"
  eval "variants=( $variants )"
  # get this libxl version
  libxlVersion="$(echo "${versionDetails}" | jq -r '.libxlVersion')"
  export libxlVersion
  # get this libxl url
  libxlUrl="$(echo "${versionDetails}" | jq -r '.libxl_url')"
  export libxlUrl
  # get this php_excel Package URL
  excelPackageUrl="$(echo "${versionDetails}" | jq -r '.excel_url')"
  export excelPackageUrl
  # get this php_excel github branch
  excelGithubBranch="$(echo "${versionDetails}" | jq -r '.branch')"
  export excelGithubBranch

  for phpVersion in "${phpVersions[@]}"; do
    export phpVersion

    # get the zts values (we may want to move this to versions.json)
    zts="$(jq -r '.[env.version].phpVersions[env.phpVersion].zts' versions-helper.json)"
    export zts

    for variant in "${variants[@]}"; do
      export variant

      # the path to this variant folder
      dir="$version/$phpVersion/$variant"
      mkdir -p "$dir"

      echo "processing $dir ..."

      {
        generated_warning
        gawk -f "$jqt" Dockerfile.template
      } >"$dir/Dockerfile"
    done
  done
done
