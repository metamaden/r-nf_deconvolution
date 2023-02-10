#!/usr/bin/env R

# Author: Sean Maden
#
# Main script to make a new example sce object.
#

require(lute)
sce.fname <- "sce-example.rda"
sce <- random_sce(num.genes = 1000, num.cells = 1000, num.types = 2,
                  expr.mean = 12, zero.include = TRUE, zero.fract = 0.4)
save(sce, file = file.path("data", sce.fname))