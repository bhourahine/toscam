MODULE masked_matrix_class

   use globalvar_ed_solver
   use masked_matrix_class_mod, only: masked_real_matrix_type, &
                                      masked_cplx_matrix_type

   IMPLICIT NONE

   private

   !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
   !$$ GENERIC (CPLX OR REAL) MASKED MATRIX CLASS $$
   !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


   INTERFACE new_masked_matrix
      MODULE PROCEDURE new_masked_matrix_from_scratch
      MODULE PROCEDURE new_masked_matrix_from_old
   END INTERFACE


   TYPE masked_matrix_type
#ifdef _complex
   TYPE(masked_cplx_matrix_type) :: rc
#else
   TYPE(masked_real_matrix_type) :: rc
#endif
   END TYPE

   public :: clean_redundant_imask
   public :: copy_masked_matrix
   public :: delete_masked_matrix
   public :: fill_masked_matrix
   public :: masked_matrix2vec
   public :: masked_matrix_type
   public :: masked_real_matrix_type
   public :: new_masked_matrix
   public :: pad_masked_matrix
   public :: read_raw_masked_matrix
   public :: slice_masked_matrix
   public :: test_masked_matrix_hermitic
   public :: vec2masked_matrix
   public :: write_masked_matrix
   public :: write_raw_masked_matrix

contains

   subroutine new_masked_matrix_from_scratch(MM, title, n1, n2, IMASK, IS_HERM)

      use masked_matrix_class_mod, only: new_masked_cplx_matrix_from_scratch, &
           new_masked_real_matrix_from_scratch

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM
      CHARACTER(LEN = *), INTENT(IN)          :: title
      INTEGER, INTENT(IN)                     :: n1, n2
      LOGICAL, OPTIONAL, INTENT(IN)           :: IS_HERM
      INTEGER, OPTIONAL, INTENT(IN)           :: IMASK(n1, n2)

#ifdef _complex
      CALL new_masked_cplx_matrix_from_scratch(MM%rc, title, n1, n2, IMASK = &
           IMASK, IS_HERM = IS_HERM)
#else
      CALL new_masked_real_matrix_from_scratch(MM%rc, title, n1, n2, IMASK = &
           IMASK, IS_HERM = IS_HERM)
#endif
   end subroutine

   subroutine new_masked_matrix_from_old(MMOUT, MMIN)

      use masked_matrix_class_mod, only: new_masked_cplx_matrix_from_old, &
           new_masked_real_matrix_from_old

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
      TYPE(masked_matrix_type), INTENT(IN)    :: MMIN

#ifdef _complex
      CALL new_masked_cplx_matrix_from_old(MMOUT%rc, MMIN%rc)
#else
      CALL new_masked_real_matrix_from_old(MMOUT%rc, MMIN%rc)
#endif
   end subroutine

   subroutine fill_masked_matrix(MM, iind, val)

      use masked_matrix_class_mod, only: fill_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM
      INTEGER, INTENT(IN)                     :: iind
#ifdef _complex
      COMPLEX(DBL) :: val
#else
      REAL(DBL)    :: val
#endif

      CALL fill_masked_matrix_(MM%rc, iind, val)

   end subroutine

   subroutine copy_masked_matrix(MMOUT, MMIN)

      use masked_matrix_class_mod, only: copy_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
      TYPE(masked_matrix_type), INTENT(IN)    :: MMIN

      CALL copy_masked_matrix_(MMOUT%rc, MMIN%rc)
   end subroutine

   subroutine delete_masked_matrix(MM)

      use masked_matrix_class_mod, only: delete_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM

      CALL delete_masked_matrix_(MM%rc)
   end subroutine

   subroutine write_raw_masked_matrix(MM, UNIT)

      use masked_matrix_class_mod, only: write_raw_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(IN) :: MM
      INTEGER, INTENT(IN)                  :: UNIT

      CALL write_raw_masked_matrix_(MM%rc, UNIT)
   end subroutine

   subroutine read_raw_masked_matrix(MM, UNIT)

      use masked_matrix_class_mod, only: read_raw_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM
      INTEGER, INTENT(IN)                     :: UNIT

      CALL read_raw_masked_matrix_(MM%rc, UNIT)
   end subroutine

   subroutine write_masked_matrix(MM, SHOW_MASK, UNIT, SHORT)

      use masked_matrix_class_mod, only: write_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(IN) :: MM
      LOGICAL, OPTIONAL, INTENT(IN)        :: SHOW_MASK
      LOGICAL, OPTIONAL, INTENT(IN)        :: SHORT
      INTEGER, OPTIONAL, INTENT(IN)        :: UNIT

      CALL write_masked_matrix_(MM%rc, SHOW_MASK = SHOW_MASK, UNIT = UNIT, &
           SHORT = SHORT)
   end subroutine

   subroutine masked_matrix2vec(MM)

      use masked_matrix_class_mod, only: masked_matrix2vec_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM

      CALL masked_matrix2vec_(MM%rc)
   end subroutine

   subroutine vec2masked_matrix(MM, MMEXT)

      use masked_matrix_class_mod, only: vec2masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT)        :: MM
      TYPE(masked_matrix_type), INTENT(IN), OPTIONAL :: MMEXT

      !CALL vec2masked_matrix_(MM%rc, MMEXT = MMEXT%rc)
      if(present(MMEXT))then
         CALL vec2masked_matrix_(MM%rc, MMEXT = MMEXT%rc)
      else
         CALL vec2masked_matrix_(MM%rc)
      endif
   end subroutine

   subroutine build_mask(MM, IMASK)

      use masked_matrix_class_mod, only: build_mask_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM
      INTEGER, OPTIONAL, INTENT(IN)           :: IMASK(:,:)

      CALL build_mask_(MM%rc, IMASK = IMASK)
   end subroutine

   subroutine test_masked_matrix_hermitic(MM)

      use masked_matrix_class_mod, only: test_masked_cplx_matrix_hermitic

      implicit none

      TYPE(masked_matrix_type), INTENT(IN) :: MM

#ifdef _complex
      CALL test_masked_cplx_matrix_hermitic(MM%rc)
#endif
   end subroutine

   subroutine pad_masked_matrix(MMOUT, MMIN)

      use masked_matrix_class_mod, only: pad_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT)        :: MMOUT
      TYPE(masked_matrix_type), INTENT(IN), OPTIONAL :: MMIN

      CALL pad_masked_matrix_(MMOUT%rc, MMIN%rc)
   end subroutine

   subroutine filter_masked_matrix(diag, MM, FILTER)

      use masked_matrix_class_mod, only: filter_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: diag
      TYPE(masked_matrix_type), INTENT(IN)    :: MM
      LOGICAL, INTENT(IN)                     :: FILTER(:,:)

      CALL filter_masked_matrix_(diag%rc, MM%rc, FILTER)
   end subroutine

   subroutine slice_masked_matrix(MMOUT, MMIN, rbounds, cbounds)

      use masked_matrix_class_mod, only: slice_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
      TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
      INTEGER, INTENT(IN)                     :: rbounds(2), cbounds(2)

      CALL slice_masked_matrix_(MMOUT%rc, MMIN%rc, rbounds, cbounds)
   end subroutine

   subroutine clean_redundant_imask(MM)

      use masked_matrix_class_mod, only: clean_redundant_imask_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MM(:)

      CALL clean_redundant_imask_(MM%rc)
   end subroutine

   subroutine transform_masked_matrix(MMOUT, MMIN, STAT)

      use masked_matrix_class_mod, only: transform_masked_matrix_

      implicit none

      TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
      TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
      CHARACTER(LEN = *), INTENT(IN)          :: STAT

      CALL transform_masked_matrix_(MMOUT%rc, MMIN%rc, STAT)
   end subroutine

end module