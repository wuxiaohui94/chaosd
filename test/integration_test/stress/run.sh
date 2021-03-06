#!/usr/bin/env bash

# Copyright 2020 Chaos Mesh Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

cur=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $cur

bin_path=../../../bin

# test cpu stress
${bin_path}/chaosd attack stress cpu -l 10 -w 1 > cpu.out

stress_ng_num=`ps aux > test.temp && grep "stress-ng" test.temp | wc -l && rm test.temp`
if [ ${stress_ng_num} -lt 1 ]; then
    echo "stress-ng is not run when executing stress cpu attack"
    exit 1
fi

uid=`cat cpu.out | grep "Attack stress cpu successfully" | awk -F: '{print $2}'`
${bin_path}/chaosd recover ${uid}

sleep 1

stress_ng_num=`ps aux > test.temp && grep "stress-ng" test.temp | wc -l && rm test.temp`
if [ ${stress_ng_num} -ne 0 ]; then
    echo "stress-ng is not stop when recovering stress mem attack"
    exit 1
fi

# test mem stress
${bin_path}/chaosd attack stress mem -w 1 > mem.out

stress_ng_num=`ps aux > test.temp && grep "stress-ng" test.temp | wc -l && rm test.temp`
if [ ${stress_ng_num} -lt 1 ]; then
    echo "stress-ng is not run when executing stress mem attack"
    exit 1
fi

uid=`cat mem.out | grep "Attack stress mem successfully" | awk -F: '{print $2}'`
${bin_path}/chaosd recover ${uid}

sleep 1

stress_ng_num=`ps aux > test.temp && grep "stress-ng" test.temp | wc -l && rm test.temp`
if [ ${stress_ng_num} -ne 0 ]; then
    echo "stress-ng is not stop when recovering stress mem attack"
    exit 1
fi

rm cpu.out
rm mem.out