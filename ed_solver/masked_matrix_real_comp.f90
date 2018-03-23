MODULE masked_matrix_class

  use globalvar_ed_solver
  use masked_matrix_class_mod, only: build_mask_, masked_real_matrix_type, &
                                     new_masked_real_matrix_from_scratch, &
                                     vec2masked_matrix_

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

  public :: masked_matrix_type
  public :: masked_real_matrix_type
  public :: new_masked_matrix
  public :: write_masked_matrix

CONTAINS

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE new_masked_matrix_from_scratch(MM,title,n1,n2,IMASK,IS_HERM)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
    CHARACTER(LEN=*),         INTENT(IN)    :: title
    INTEGER,                  INTENT(IN)    :: n1,n2
    LOGICAL, OPTIONAL,        INTENT(IN)    :: IS_HERM
    INTEGER, OPTIONAL,        INTENT(IN)    :: IMASK(n1,n2)
#ifdef _complex
    CALL new_masked_cplx_matrix_from_scratch(MM%rc,title,n1,n2,IMASK=IMASK,IS_HERM=IS_HERM)
#else
    CALL new_masked_real_matrix_from_scratch(MM%rc,title,n1,n2,IMASK=IMASK,IS_HERM=IS_HERM)
#endif
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE new_masked_matrix_from_old(MMOUT,MMIN) 
    TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
    TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
#ifdef _complex
    CALL new_masked_cplx_matrix_from_old(MMOUT%rc,MMIN%rc)
#else
    CALL new_masked_real_matrix_from_old(MMOUT%rc,MMIN%rc)
#endif
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE fill_masked_matrix(MM,iind,val)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
#ifdef _complex
    COMPLEX(DBL) :: val
#else
    REAL(DBL)    :: val
#endif
    INTEGER,                  INTENT(IN)    :: iind
    CALL fill_masked_matrix_(MM%rc,iind,val)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE copy_masked_matrix(MMOUT,MMIN)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
    TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
    CALL copy_masked_matrix_(MMOUT%rc,MMIN%rc)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE delete_masked_matrix(MM)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
      CALL delete_masked_matrix_(MM%rc)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE write_raw_masked_matrix(MM,UNIT)
    TYPE(masked_matrix_type), INTENT(IN) :: MM
    INTEGER,                  INTENT(IN) :: UNIT
    CALL write_raw_masked_matrix_(MM%rc,UNIT)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE read_raw_masked_matrix(MM,UNIT)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
    INTEGER,                  INTENT(IN)    :: UNIT
    CALL read_raw_masked_matrix_(MM%rc,UNIT)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE write_masked_matrix(MM,SHOW_MASK,UNIT,SHORT)
    TYPE(masked_matrix_type), INTENT(IN) :: MM
    LOGICAL, OPTIONAL,        INTENT(IN) :: SHOW_MASK
    LOGICAL, OPTIONAL,        INTENT(IN) :: SHORT
    INTEGER, OPTIONAL,        INTENT(IN) :: UNIT
    CALL write_masked_matrix_(MM%rc,SHOW_MASK=SHOW_MASK,UNIT=UNIT,SHORT=SHORT)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE masked_matrix2vec(MM)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
    CALL masked_matrix2vec_(MM%rc)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE vec2masked_matrix(MM,MMEXT)
    TYPE(masked_matrix_type), INTENT(INOUT)        :: MM
    TYPE(masked_matrix_type), INTENT(IN), OPTIONAL :: MMEXT
   !CALL vec2masked_matrix_(MM%rc,MMEXT=MMEXT%rc)
    if(present(MMEXT))then
     CALL vec2masked_matrix_(MM%rc,MMEXT=MMEXT%rc)
    else
     CALL vec2masked_matrix_(MM%rc)
    endif
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE build_mask(MM,IMASK)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM
    INTEGER, OPTIONAL,        INTENT(IN)    :: IMASK(:,:)
    CALL build_mask_(MM%rc,IMASK=IMASK)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE test_masked_matrix_hermitic(MM)
    TYPE(masked_matrix_type), INTENT(IN) :: MM
#ifdef _complex
    CALL test_masked_cplx_matrix_hermitic(MM%rc)
#endif
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE pad_masked_matrix(MMOUT,MMIN)
    TYPE(masked_matrix_type), INTENT(INOUT)        :: MMOUT
    TYPE(masked_matrix_type), INTENT(IN), OPTIONAL :: MMIN
    CALL pad_masked_matrix_(MMOUT%rc,MMIN%rc)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE filter_masked_matrix(diag,MM,FILTER)
    TYPE(masked_matrix_type), INTENT(INOUT) :: diag
    TYPE(masked_matrix_type), INTENT(IN)    :: MM
    LOGICAL,                  INTENT(IN)    :: FILTER(:,:)
    CALL filter_masked_matrix_(diag%rc,MM%rc,FILTER)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE slice_masked_matrix(MMOUT,MMIN,rbounds,cbounds)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
    TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
    INTEGER,                  INTENT(IN)    :: rbounds(2),cbounds(2)
    CALL slice_masked_matrix_(MMOUT%rc,MMIN%rc,rbounds,cbounds)
  END SUBROUTINE 

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE clean_redundant_imask(MM)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MM(:)
    CALL clean_redundant_imask_(MM%rc)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

  SUBROUTINE transform_masked_matrix(MMOUT,MMIN,STAT)
    TYPE(masked_matrix_type), INTENT(INOUT) :: MMOUT
    TYPE(masked_matrix_type), INTENT(IN)    :: MMIN
    CHARACTER(LEN=*),         INTENT(IN)    :: STAT
    CALL transform_masked_matrix_(MMOUT%rc,MMIN%rc,STAT)
  END SUBROUTINE

!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************
!**************************************************************************

END MODULE 



