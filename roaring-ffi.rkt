#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)


(provide roaring-bitmap-andnot
         roaring-bitmap-add!?
         roaring-bitmap->bytes
         roaring-bitmap-and
         roaring-bitmap-empty?
         roaring-bitmap-xor!
         roaring-bitmap?
         roaring-bitmap-clear!
         bytes->roaring-bitmap
         roaring-bitmap-remove-all!
         range->roaring-bitmap
         roaring-bitmap-remove-run-compression!
         roaring-bitmap-remove!
         roaring-bitmap-xor/count
         roaring-bitmap-contains?
         roaring-bitmap-count-in-range
         roaring-bitmap-xor
         roaring-bitmap-intersect?
         roaring-bitmap-remove-vector!
         roaring-bitmap-or
         roaring-bitmap-jaccard-index
         roaring-bitmap-count
         roaring-bitmap-andnot!
         make-roaring-bitmap
         roaring-bitmap-remove!?
         roaring-bitmap-add!
         roaring-bitmap-shrink!
         roaring-bitmap-add-vector!
         roaring-bitmap-add-all!
         roaring-bitmap->vector
         roaring-bitmap-intersect?/range
         roaring-bitmap-andnot/count
         roaring-bitmap-copy
         roaring-bitmap-or!
         roaring-bitmap-add-range!
         roaring-bitmap-remove-range!
         roaring-bitmap-and/count
         roaring-bitmap-xor/list
         roaring-bitmap-and!
         roaring-bitmap-or/list
         roaring-bitmap-or/count
         roaring-bitmap-copy!
         roaring-bitmap-contains?/range
         roaring-bitmap-run-optimize!)
 


(define-ffi-definer define-roaring (ffi-lib "roaring"))

#|
(define-cstruct _roaring_array
  ([size _int32]
   [allocation_size _int32]
   [containers _pointer]
   [keys _pointer]
   [typecodes _pointer]
   [flags _uint8])
  #:malloc-mode 'atomic-interior)

(define-cstruct _roaring_bitmap
  ([high_low_container _roaring_array])
  #:malloc-mode 'atomic-interior)
|#

(struct roaring-bitmap (ptr)
  #:property prop:sequence
  (λ (r)
    (make-do-sequence
     (λ ()
       (values
        roaring-iterator-value
        roaring-iterator-next!
        (roaring-bitmap-iterator r)
        roaring-iterator-has-value?
        #f
        #f)))))
        
        
        
        
        
  
(define _rbmp*/null
  (make-ctype (_or-null _pointer)
              (λ (v)
                ;(displayln v)
                (if (roaring-bitmap? v) (roaring-bitmap-ptr v) v))
              (λ (p)
                (when p
                  ;(displayln p)
                  (register-finalizer p roaring_bitmap_free))
                (and p (roaring-bitmap p)))))

(define _rbmp*
  (make-ctype _pointer
              (λ (v)
                (if (roaring-bitmap? v) (roaring-bitmap-ptr v) v))
              (λ (p)
                (register-finalizer p roaring_bitmap_free)
                (roaring-bitmap p))))

(define-roaring roaring_bitmap_create_with_capacity
  (_fun _uint32 -> _rbmp*/null))

(define-roaring roaring_bitmap_free
  (_fun _pointer -> _void))

(define (make-roaring-bitmap [cap 0])
  (roaring_bitmap_create_with_capacity cap))

#|
/**
 * Add all the values between min (included) and max (excluded) that are at a
 * distance k*step from min.
*/
roaring_bitmap_t *roaring_bitmap_from_range(uint64_t min, uint64_t max,
                                            uint32_t step);
|#


(define-roaring range->roaring-bitmap
  (_fun _uint64 _uint64 _uint32 -> _rbmp*/null)
  #:c-id roaring_bitmap_from_range)

#|
/**
 * Add all the values between min (included) and max (excluded) that are at a
 * distance k*step from min.
*/
roaring_bitmap_t *roaring_bitmap_from_range(uint64_t min, uint64_t max,
                                            uint32_t step);
|#

(define-roaring roaring_bitmap_of_ptr
  (_fun _size (_vector i _uint32) -> _rbmp*/null))

(define (vector->roaring-bitmap von)
  (roaring_bitmap_of_ptr (vector-length von) von))

(define (list->roaring-bitmap lon)
  (vector->roaring-bitmap (list->vector lon)))


#|
/**
 * Copies a bitmap (this does memory allocation).
 * The caller is responsible for memory management.
 */
roaring_bitmap_t *roaring_bitmap_copy(const roaring_bitmap_t *r);
|#

(define-roaring roaring-bitmap-copy 
  (_fun _rbmp* -> _rbmp*/null)
  #:c-id roaring_bitmap_copy)


#|
/**
 * Copies a bitmap from src to dest. It is assumed that the pointer dest
 * is to an already allocated bitmap. The content of the dest bitmap is
 * freed/deleted.
 *
 * It might be preferable and simpler to call roaring_bitmap_copy except
 * that roaring_bitmap_overwrite can save on memory allocations.
 */
bool roaring_bitmap_overwrite(roaring_bitmap_t *dest,
                              const roaring_bitmap_t *src);
|#

(define-roaring roaring-bitmap-copy!
  (_fun {dest : _rbmp*} _rbmp* -> _stdbool)
  #:c-id roaring_bitmap_overwrite)


#|
/**
 * Computes the intersection between two bitmaps and returns new bitmap. The
 * caller is responsible for memory management.
 */
roaring_bitmap_t *roaring_bitmap_and(const roaring_bitmap_t *r1,
                                     const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-and
  (_fun _rbmp* _rbmp* -> _rbmp*/null)
  #:c-id roaring_bitmap_and)
#|
/**
 * Computes the size of the intersection between two bitmaps.
 */
uint64_t roaring_bitmap_and_cardinality(const roaring_bitmap_t *r1,
                                        const roaring_bitmap_t *r2);
|#


(define-roaring roaring-bitmap-and/count
  (_fun _rbmp* _rbmp* -> _uint64)
  #:c-id roaring_bitmap_and_cardinality)

#|
/**
 * Check whether two bitmaps intersect.
 */
bool roaring_bitmap_intersect(const roaring_bitmap_t *r1,
                              const roaring_bitmap_t *r2);
|#


(define-roaring roaring-bitmap-intersect?
  (_fun _rbmp* _rbmp* -> _bool)
  #:c-id roaring_bitmap_intersect)

#|
/**
 * Check whether a bitmap and a closed range intersect.
 */
bool roaring_bitmap_intersect_with_range(const roaring_bitmap_t *bm,
                                         uint64_t x, uint64_t y);
|#

(define-roaring roaring-bitmap-intersect?/range
  (_fun _rbmp* _uint64 _uint64 -> _bool)
  #:c-id roaring_bitmap_intersect_with_range)


#|
/**
 * Computes the Jaccard index between two bitmaps. (Also known as the Tanimoto
 * distance, or the Jaccard similarity coefficient)
 *
 * The Jaccard index is undefined if both bitmaps are empty.
 */
double roaring_bitmap_jaccard_index(const roaring_bitmap_t *r1,
                                    const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-jaccard-index
  (_fun _rbmp* _rbmp* -> _double)
  #:c-id roaring_bitmap_jaccard_index)

#|
/**
 * Computes the size of the union between two bitmaps.
 */
uint64_t roaring_bitmap_or_cardinality(const roaring_bitmap_t *r1,
                                       const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-or/count
  (_fun _rbmp* _rbmp* -> _uint64)
  #:c-id roaring_bitmap_or_cardinality)

#|
/**
 * Computes the size of the difference (andnot) between two bitmaps.
 */
uint64_t roaring_bitmap_andnot_cardinality(const roaring_bitmap_t *r1,
                                           const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-andnot/count
  (_fun _rbmp* _rbmp* -> _uint64)
  #:c-id roaring_bitmap_andnot_cardinality)

#|

/**
 * Computes the size of the symmetric difference (xor) between two bitmaps.
 */
uint64_t roaring_bitmap_xor_cardinality(const roaring_bitmap_t *r1,
                                        const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-xor/count
  (_fun _rbmp* _rbmp* -> _uint64)
  #:c-id roaring_bitmap_xor_cardinality)



#|
/**
 * Inplace version of `roaring_bitmap_and()`, modifies r1
 * r1 == r2 is allowed
 */
void roaring_bitmap_and_inplace(roaring_bitmap_t *r1,
                                const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-and!
  (_fun _rbmp* _rbmp* -> _void)
  #:c-id roaring_bitmap_and_inplace)


#|
/**
 * Computes the union between two bitmaps and returns new bitmap. The caller is
 * responsible for memory management.
 */
roaring_bitmap_t *roaring_bitmap_or(const roaring_bitmap_t *r1,
                                    const roaring_bitmap_t *r2);

/**
 * Inplace version of `roaring_bitmap_or(), modifies r1.
 * TODO: decide whether r1 == r2 ok
 */
void roaring_bitmap_or_inplace(roaring_bitmap_t *r1,
                               const roaring_bitmap_t *r2);


|#


(define-roaring roaring-bitmap-or
  (_fun _rbmp* _rbmp* -> _rbmp*/null)
  #:c-id roaring_bitmap_or)

(define-roaring roaring-bitmap-or!
  (_fun _rbmp* _rbmp* -> _void)
  #:c-id roaring_bitmap_or_inplace)

(define-roaring roaring_bitmap_or_many
  (_fun _size (_list i _rbmp*) -> _rbmp*/null))

(define-roaring roaring_bitmap_or_many_heap
  (_fun _uint32 (_list i _rbmp*) -> _rbmp*/null))

(define (roaring-bitmap-or/list lor [heap? #f])
  (if heap?
      (roaring_bitmap_or_many_heap (length lor) lor)
      (roaring_bitmap_or_many (length lor) lor)))

#|
/**
 * Computes the symmetric difference (xor) between two bitmaps
 * and returns new bitmap. The caller is responsible for memory management.
 */
roaring_bitmap_t *roaring_bitmap_xor(const roaring_bitmap_t *r1,
                                     const roaring_bitmap_t *r2);
|#

(define-roaring roaring-bitmap-xor
  (_fun _rbmp* _rbmp* -> _rbmp*/null)
  #:c-id roaring_bitmap_xor)

(define-roaring roaring-bitmap-xor!
  (_fun _rbmp* _rbmp* -> _void)
  #:c-id roaring_bitmap_xor_inplace)

(define-roaring roaring_bitmap_xor_many
  (_fun _size (_list i _rbmp*) -> _rbmp*/null))

(define (roaring-bitmap-xor/list lor)
  (roaring_bitmap_xor_many (length lor) lor))


(define-roaring roaring-bitmap-andnot
  (_fun _rbmp* _rbmp* -> _rbmp*)
  #:c-id roaring_bitmap_andnot)

(define-roaring roaring-bitmap-andnot!
  (_fun _rbmp* _rbmp* -> _void)
  #:c-id roaring_bitmap_andnot_inplace)


;;;;;;;;;;;;;;;;;;;;;


(define-roaring roaring-bitmap-add!
  (_fun _rbmp* _uint32 -> _void)
  #:c-id roaring_bitmap_add)

(define-roaring roaring-bitmap-add!?
  (_fun _rbmp* _uint32 -> _bool)
  #:c-id roaring_bitmap_add_checked)

(define-roaring roaring_bitmap_add_many
  (_fun _rbmp* _size (_vector i _uint32) -> _void))

(define (roaring-bitmap-add-vector! rb vec)
  (roaring_bitmap_add_many rb (vector-length vec) vec))

(define (roaring-bitmap-add-all! rb seq)
  (let ([v (for/vector ([v seq]) v)])
    (roaring_bitmap_add_many rb (vector-length v) v)))

#|
/**
 * Add all values in range [min, max]
 */
void roaring_bitmap_add_range_closed(roaring_bitmap_t *r,
                                     uint32_t min, uint32_t max);
|#

(define-roaring roaring_bitmap_add_range_closed
  (_fun _rbmp* _uint32 _uint32 -> _void))

(define (roaring-bitmap-add-range! r min max [closed? #f])
  (roaring_bitmap_add_range_closed r min (if closed? max (sub1 max))))


(define-roaring roaring-bitmap-remove!
  (_fun _rbmp* _uint32 -> _void)
  #:c-id roaring_bitmap_remove)

(define-roaring roaring-bitmap-remove!?
  (_fun _rbmp* _uint32 -> _bool)
  #:c-id roaring_bitmap_remove_checked)

(define-roaring roaring_bitmap_remove_range_closed
  (_fun _rbmp* _uint32 _uint32 -> _void))

(define (roaring-bitmap-remove-range! r min max [closed? #f])
  (roaring_bitmap_remove_range_closed r min (if closed? max (sub1 max))))

(define-roaring roaring_bitmap_remove_many
  (_fun _rbmp* _size (_vector i _uint32) -> _void))

(define (roaring-bitmap-remove-vector! r v)
  (roaring_bitmap_remove_many r (vector-length v) v))

(define (roaring-bitmap-remove-all! r seq)
  (let ([v (for/vector ([v seq]) v)])
    (roaring-bitmap-remove-vector! r v)))




(define-roaring roaring-bitmap-contains?
  (_fun _rbmp* _uint32 -> _bool)
  #:c-id roaring_bitmap_contains)

(define-roaring roaring-bitmap-contains?/range
  (_fun _rbmp* _uint32 _uint32 -> _stdbool)
  #:c-id roaring_bitmap_contains_range)


(define-roaring roaring-bitmap-count
  (_fun _rbmp* -> _uint64)
  #:c-id roaring_bitmap_get_cardinality)

(define-roaring roaring-bitmap-count-in-range
  (_fun _rbmp* _uint32 _uint32 -> _uint64)
  #:c-id roaring_bitmap_range_cardinality)


(define-roaring roaring-bitmap-empty?
  (_fun _rbmp* -> _uint64)
  #:c-id roaring_bitmap_is_empty)

(define-roaring roaring-bitmap-clear!
  (_fun _rbmp* -> _void)
  #:c-id roaring_bitmap_clear)

(define-roaring roaring-bitmap->vector
  (_fun {r : _rbmp*}
        {ans : (_vector o _uint32 (roaring-bitmap-count r))}
        -> _void -> ans)
  #:c-id roaring_bitmap_to_uint32_array)
                 
#||||||||||||||||||||||||||||||||||||||||| TWEAKS |||||||||||||||||||||||||||||||||||||||||||||||||||#

(define-roaring roaring-bitmap-remove-run-compression!
  (_fun _rbmp* -> _stdbool)
  #:c-id roaring_bitmap_remove_run_compression)

(define-roaring roaring-bitmap-run-optimize!
  (_fun _rbmp* -> _stdbool)
  #:c-id roaring_bitmap_run_optimize)

(define-roaring roaring-bitmap-shrink!
  (_fun _rbmp* -> _size)
  #:c-id roaring_bitmap_shrink_to_fit)


#||||||||||||||||||||||||||||||||||||| SERIALIZATION ||||||||||||||||||||||||||||||||||||||||||||||||#

;; size_t roaring_bitmap_size_in_bytes(const roaring_bitmap_t *r);

(define-roaring roaring_bitmap_size_in_bytes
  (_fun _rbmp* -> _size))

(define-roaring roaring-bitmap->bytes
  (_fun {r : _rbmp*}
        {buffer : (_bytes o (roaring_bitmap_size_in_bytes r))}
        -> _size -> buffer)
  #:c-id roaring_bitmap_serialize)

(define-roaring bytes->roaring-bitmap
  (_fun _bytes -> _rbmp*/null)
  #:c-id roaring_bitmap_deserialize)



#|||||||||||||||||||||||||||||||||||| ITERATOR STUFF ||||||||||||||||||||||||||||||||||||||||||||||||#

(define-cstruct _roaring_uint32_iterator
  ([parent _pointer]
   [container_index _int32]
   [in_container_index _int32]
   [run_index _int32]
   [current_value _uint32]
   [has_value _stdbool]
   [container _pointer]
   [typecode _uint8]
   [highbits _uint32])
  #:malloc-mode 'atomic-interior)

(struct roaring-iterator (ptr))
(define _ritr*
  (make-ctype _roaring_uint32_iterator-pointer
              (λ (v)
                (if (roaring-iterator? v) (roaring-iterator-ptr v) v))
              (λ (p)
                (register-finalizer p roaring_iterator_free)
                (roaring-iterator p))))


(define-roaring roaring-bitmap-iterator
  (_fun _rbmp* -> _ritr*)
  #:c-id roaring_create_iterator)

(define-roaring roaring_iterator_free
  (_fun _ritr* -> _void)
  #:c-id roaring_free_uint32_iterator)

(define-roaring roaring-iterator-advance!
  (_fun _ritr* -> _bool)
  #:c-id roaring_advance_uint32_iterator)

(define (roaring-iterator-next! itr)
  (roaring-iterator-advance! itr)
  itr)
       
(define (roaring-iterator-has-value? ritr)
  (roaring_uint32_iterator-has_value (roaring-iterator-ptr ritr)))

(define (roaring-iterator-value ritr)
  (roaring_uint32_iterator-current_value (roaring-iterator-ptr ritr)))