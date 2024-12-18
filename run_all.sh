#!/usr/bin/env bash

# Loop through t1.txt, t2.txt, t3.txt, t4.txt
for i in {1..4}; do
  echo "Running test t$i.txt..."
  ./install_and_run.sh "t$i.txt"
done

