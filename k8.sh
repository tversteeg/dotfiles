#!/bin/bash

fzf_opts='--layout=reverse'

case $1 in
  short)
    namespace="$(kubectl get namespace -o name | fzf $fzf_opts)"

    value="$(kubectl get "pod" -o name -n "${namespace##*/}" | fzf $fzf_opts)"

    echo "${value##*/}"
    ;; 
  *)
    fzf_opts='--layout=reverse'

    resource="${1:-pod}"

    namespace="$(kubectl get namespace -o name | fzf $fzf_opts)"

    value="$(kubectl get $resource -o name -n "${namespace##*/}" | fzf $fzf_opts)"

    echo "-n ${namespace##*/} ${value##*/}"
esac
