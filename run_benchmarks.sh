#!/bin/sh

printf "== Creation ==\n"
time luajit ./caress/benchmarks/classes/creation.lua

printf "\n"

printf "== Attribute Access ==\n"
time luajit ./caress/benchmarks/classes/attr_access.lua

printf "\n"

printf "== Method Calling ==\n"
time luajit ./caress/benchmarks/classes/method_calling.lua

printf "\n"

printf "== Derived Class Method Calling ==\n"
time luajit ./caress/benchmarks/classes/derived_method_calling.lua
