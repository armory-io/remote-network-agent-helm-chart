#!/usr/bin/env bash

helm template -f scratch/values.yaml . > scratch/manifests.yaml