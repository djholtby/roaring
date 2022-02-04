#lang info
(define collection "roaring")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/roaring.scrbl" ())))
(define pkg-desc "FFI bindings for CRoaringBitmap")
(define version "0.0")
(define pkg-authors '(djholtby))
(define license '(Apache-2.0 OR MIT))
