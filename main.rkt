#lang racket/base


(require "roaring-ffi.rkt"
         racket/contract/base racket/sequence)


(provide
 
 (contract-out [roaring-bitmap? (-> any/c boolean?)]
               [make-roaring-bitmap (->* () (exact-nonnegative-integer?) (or/c #f roaring-bitmap?))]
               [range->roaring-bitmap
                (-> exact-nonnegative-integer? exact-nonnegative-integer? exact-nonnegative-integer?
                     (or/c #f roaring-bitmap?))]
               [roaring-bitmap-copy (-> roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-copy! (-> roaring-bitmap? roaring-bitmap? boolean?)]
               [roaring-bitmap-and (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-or (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-xor (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-andnot (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-and! (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-or! (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-xor! (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-andnot! (-> roaring-bitmap? roaring-bitmap? roaring-bitmap?)]
               [roaring-bitmap-and/count (-> roaring-bitmap? roaring-bitmap?
                                              exact-nonnegative-integer?)]
               [roaring-bitmap-or/count (-> roaring-bitmap? roaring-bitmap?
                                              exact-nonnegative-integer?)]
               [roaring-bitmap-xor/count (-> roaring-bitmap? roaring-bitmap?
                                              exact-nonnegative-integer?)]
               [roaring-bitmap-andnot/count (-> roaring-bitmap? roaring-bitmap?
                                              exact-nonnegative-integer?)]
               [roaring-bitmap-intersect? (-> roaring-bitmap? roaring-bitmap? boolean?)]
               [roaring-bitmap-intersect?/range (->i ([r roaring-bitmap?]
                                                     [min exact-nonnegative-integer?]
                                                     [max exact-nonnegative-integer?])
                                                     #:pre/desc (min max)
                                                     (or (< min max)
                                                         (format "Invalid range: [~a:~a]" min max))
                                                     [ans boolean?])]
               [roaring-bitmap-jaccard-index (-> roaring-bitmap? roaring-bitmap? real?)]

               [roaring-bitmap-or/list (->* ((listof roaring-bitmap?)) (any/c)
                                            (or/c #f roaring-bitmap?))]
               [roaring-bitmap-xor/list (-> (listof roaring-bitmap?)
                                             (or/c #f roaring-bitmap?))]

               [roaring-bitmap-add! (-> roaring-bitmap? exact-nonnegative-integer? void?)]
               [roaring-bitmap-add!? (-> roaring-bitmap? exact-nonnegative-integer? boolean?)]
               [roaring-bitmap-add-vector! (-> roaring-bitmap? (vectorof exact-nonnegative-integer?)
                                               void?)]
               [roaring-bitmap-add-all! (-> roaring-bitmap? (sequence/c exact-nonnegative-integer?)
                                            void?)]
               [roaring-bitmap-add-range! (->i ([r roaring-bitmap?]
                                                [min exact-nonnegative-integer?]
                                                [max exact-nonnegative-integer?])
                                               ([closed? boolean?])
                                               #:pre/desc (min max)
                                               (or (< min max)
                                                   (format "Invalid range: [~a:~a]" min max))
                                               [res void?])]
                                               
               [roaring-bitmap-remove! (-> roaring-bitmap? exact-nonnegative-integer? void?)]
               [roaring-bitmap-remove!? (-> roaring-bitmap? exact-nonnegative-integer? boolean?)]
               [roaring-bitmap-remove-vector! (-> roaring-bitmap?
                                                  (vectorof exact-nonnegative-integer?) void?)]
               [roaring-bitmap-remove-all! (-> roaring-bitmap?
                                               (sequence/c exact-nonnegative-integer?) void?)]
               [roaring-bitmap-remove-range! (->i ([r roaring-bitmap?]
                                                [min exact-nonnegative-integer?]
                                                [max exact-nonnegative-integer?])
                                               ([closed? boolean?])
                                               #:pre/desc (min max)
                                               (or (< min max)
                                                   (format "Invalid range: [~a:~a]" min max))
                                               [res void?])]

               [roaring-bitmap-contains? (-> roaring-bitmap? exact-nonnegative-integer? boolean?)]
               [roaring-bitmap-contains?/range
                (->i ([r roaring-bitmap?]
                      [min exact-nonnegative-integer?]
                      [max exact-nonnegative-integer?])
                     ()
                     #:pre/desc (min max)
                     (or (< min max)
                         (format "Invalid range: [~a:~a]" min max))
                     [ans boolean?])]

               [roaring-bitmap-count (-> roaring-bitmap? exact-nonnegative-integer?)]
               [roaring-bitmap-count-in-range (->i ([r roaring-bitmap?]
                                                    [min exact-nonnegative-integer?]
                                                    [max exact-nonnegative-integer?])
                                                   ()
                                                   #:pre/desc (min max)
                                                   (or (< min max)
                                                       (format "Invalid range: [~a:~a]" min max))
                                                   [ans exact-nonnegative-integer?])]
               [roaring-bitmap-empty? (-> roaring-bitmap? boolean?)]
               [roaring-bitmap-clear! (-> roaring-bitmap? void?)]
               [roaring-bitmap->vector (-> roaring-bitmap? (vectorof exact-nonnegative-integer?))]

               [roaring-bitmap-remove-run-compression! (-> roaring-bitmap? boolean?)]
               [roaring-bitmap-run-optimize! (-> roaring-bitmap? boolean?)]
               [roaring-bitmap-shrink! (-> roaring-bitmap? exact-nonnegative-integer?)]

               [roaring-bitmap->bytes (-> roaring-bitmap? bytes?)]
               [bytes->roaring-bitmap (-> bytes? (or/c #f roaring-bitmap?))]))
 