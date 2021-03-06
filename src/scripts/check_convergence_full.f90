
!======================!
!======================!

program dmft_check_convergence
!---------------!
   ! use DMFT_SOLVER_ED
   !use dmftmod
   use genvar
   use init_and_close_my_sim, only: initialize_my_simulation, finalize_my_simulation
   ! use fortran_cuda
   use matrix
   use StringManip
   !use DLPLOT
   !use plotlib
   !use plot2d
!---------------!
   implicit none

   integer                :: fac, mmax, paramagnet
   integer                :: n_frequ_long, i1, i2, kk_, i, j, k, l, channels, n_frequ
   complex(kind=DP), allocatable :: Smat(:, :, :), frequ_(:), green_lat(:, :, :, :), green_matsu(:, :, :, :), sigma_lat(:, :, :, :)
   logical                :: check, check2, checkfile
   real(kind=DP)                :: mmu, vv, deltafrequ, inifrequ
   complex(kind=DP)             :: tt, ttt
   complex(kind=DP), allocatable :: t1(:), t2(:), t3(:), dummy(:, :), dummy2(:, :), iwplusmu(:, :), t_trace1(:, :), t_trace2(:, :)
   complex(kind=DP), allocatable :: tt1(:, :, :)
   real(kind=DP), allocatable    :: dens(:, :)
   real(kind=DP)                :: beta, total_density
   real(kind=DP), allocatable    :: temp(:), vvv(:, :)

   call initialize_my_simulation
   testing = .false.
   fast_invmat = .true.
   use_cuda_routines = .false.
   use_cula_routines = .false.
   force_invmat_single_prec = .false.
   use_openmp_invmat = .false.
   diag_use_LU_instead_of_pivot = .false.
   flag_use_invmat_jordan = .true.
   flag_use_invmat_jordan_real = .true.
   enable_mpi_dot = .false.

   write (*, *) 'lattice green function'

   do kk_ = 1, 2
      if (kk_ == 2) then
      call system(" ls green_onetep_spin_full_check_convergence2 || cp green_onetep_spin_full_check_convergence1 green_onetep_spin_full_check_convergence2 ")
      endif
      open (unit=10012, file="green_onetep_spin_full_check_convergence"//TRIM(ADJUSTL(toString(kk_))), form='unformatted')
      read (10012) n_frequ, channels
      write (*, *) 'Nfrequ channels : ', n_frequ, channels
     if(.not.allocated(Smat)) allocate(Smat(channels,channels,2),frequ_(n_frequ),green_lat(n_frequ,channels,channels,2),sigma_lat(n_frequ,channels,channels,2))
      read (10012) mmu, Smat(:, :, kk_)
      do i = 1, n_frequ
         read (10012) frequ_(i), green_lat(i, :, :, kk_), sigma_lat(i, :, :, kk_)
      enddo
      close (10012)
   enddo
   deltafrequ = frequ_(2) - frequ_(1); inifrequ = frequ_(1)
   write (*, *) 'read impurity green function'

   inquire (file='green_output_matsu_full_long_1', exist=check)
   !===========================================================!
   if (check) then

      open (unit=1000, file='green_output_matsu_full_long_1', form='unformatted')
      i = 0
      do
         read (1000, end=111)
         i = i + 1
      enddo
111   continue
      close (1000)
      write (*, *) 'nmatsu_long is : ', i
      n_frequ_long = i

      allocate (green_matsu(n_frequ_long, channels, channels, 2))

      do j = 1, 2
      if (j == 2) then
         call system(" ls green_output_matsu_full_long_2 || cp green_output_matsu_full_long_1 green_output_matsu_full_long_2 ")
      endif
      open (unit=1000, file='green_output_matsu_full_long_'//TRIM(ADJUSTL(toString(j))), form='unformatted')
      do i = 1, n_frequ_long
         write (*, *) 'reading frequ : ', i, n_frequ_long
         read (1000) green_matsu(i, :, :, j)
      enddo
      close (1000)
      enddo
      write (*, *) 'done'

      !===========================================================!

   else
      !===========================================================!

      inquire (file='green_output_matsu_full1', exist=check2)
      if (check2) then
         allocate (green_matsu(n_frequ, channels, channels, 2))
         n_frequ_long = n_frequ
         do j = 1, 2
         if (j == 2) then
            call system(" ls green_output_matsu_full2 || cp green_output_matsu_full1 green_output_matsu_full2 ")
         endif
         open (unit=1000, file='green_output_matsu_full'//TRIM(ADJUSTL(toString(j))), form='unformatted')
         do i = 1, n_frequ
            write (*, *) 'reading frequ : ', i, n_frequ
            write (*, *) 'SHAPE GREEN MATSU : ', shape(green_matsu(i, :, :, j))
            read (1000) green_matsu(i, :, :, j)
         enddo
         close (1000)
         enddo
         write (*, *) 'done'
      else

         INQUIRE (file='green_output', exist=checkfile)
         if (checkfile) then
            write (*, *) 'is it a paramagnet ? (=1 for true)'
            read (*, *) paramagnet
            fac = 4; if (paramagnet == 1) fac = fac/2; mmax = 2; if (paramagnet == 1) mmax = 1
            if (.not. allocated(temp)) allocate (temp(fac*channels), vvv(channels, 2))
            open (unit=1000, file='green_output')
            read (1000, *)
            j = 0
            do
               read (1000, *, end=213)
               j = j + 1
            enddo
213         continue; n_frequ_long = j; rewind (1000); read (1000, *)
            allocate (green_matsu(n_frequ_long, channels, channels, 2))
            do i = 1, n_frequ_long
               read (1000, *) vv, (temp(k), k=1, fac*channels)
               do j = 1, mmax
                  green_matsu(i, :, :, j) = 0.d0
                  do k = 1, channels
                     green_matsu(i, k, k, j) = temp(channels*(j - 1)*2 + 2*k - 1) + imi*temp(channels*(j - 1)*2 + 2*k)
                  enddo
                  if (paramagnet == 1) green_matsu(i, :, :, 2) = green_matsu(i, :, :, 1)
               enddo
            enddo
            close (1000)

         else
            allocate (green_matsu(n_frequ, channels, channels, 2))
            n_frequ_long = n_frequ
            write (*, *) 'FILE green_output_matsu_full not present (probably running single site DMFT version)'
            write (*, *) 'green_imp=green_lat, in order to carry on and compute density'
            green_matsu = green_lat

         endif
      endif

   endif
   !===========================================================!

   if (.not. allocated(dens)) allocate (dens(channels, channels))
   if(.not.allocated(dummy))    allocate(t1(channels),t2(channels),t3(channels),dummy(channels,channels),dummy2(channels,channels),iwplusmu(channels,channels))
   if (.not. allocated(t_trace1)) allocate (t_trace1(channels, channels), t_trace2(channels, channels))

   beta = dacos(-1.d0)/aimag(frequ_(1))

   write (*, *) 'Smat up        :  ', Smat(:, :, 1)
   write (*, *) 'Smat dn        :  ', Smat(:, :, 2)
   write (*, *) 'Chem           :  ', mmu
   write (*, *) 'beta           :  ', beta

   do kk_ = 1, 2

      if (allocated(tt1)) deallocate (tt1)
      allocate (tt1(channels, channels, n_frequ_long))

      do k = 1, channels
         open (1010 + 100*k + 1000*kk_, file='compare_imp_'//TRIM(ADJUSTL(toString(k)))//"_"//TRIM(ADJUSTL(toString(kk_))))
         open (1011 + 100*k + 1000*kk_, file='compare_lat_'//TRIM(ADJUSTL(toString(k)))//"_"//TRIM(ADJUSTL(toString(kk_))))
         open (1012 + 100*k + 1000*kk_, file='diff_gm1_'//TRIM(ADJUSTL(toString(k)))//"_"//TRIM(ADJUSTL(toString(kk_))))
      enddo
   enddo

   open (unit=100, file='rho_fermi_level_from_gimp')
   open (unit=101, file='rho_fermi_level_from_gproj')
   open (unit=102, file='rho_n_tot_from_gimp')
   open (unit=103, file='rho_matrix_from_gimp')

   total_density = 0.d0

   do kk_ = 1, 2

      do i = 1, n_frequ

         dummy2 = green_lat(i, :, :, kk_)
         call invmat(channels, dummy2)
         dummy = green_matsu(i, :, :, kk_)
         call invmat(channels, dummy)

         iwplusmu = 0.
         do k = 1, channels
            iwplusmu(k, k) = frequ_(i) + mmu
         enddo

         dummy = dummy + MATMUL(iwplusmu, (Smat(:, :, kk_) - Id(channels)))
         t3 = diag(dummy - dummy2)

         call invmat(channels, dummy)
         tt1(:, :, i) = dummy
         t1 = diag(dummy)
         t2 = diag(green_lat(i, :, :, kk_))
         t_trace1 = matmul(dummy, Smat(:, :, kk_))
         t_trace2 = matmul(green_lat(i, :, :, kk_), Smat(:, :, kk_))
         do k = 1, channels
            write (1010 + 100*k + 1000*kk_, *) aimag(frequ_(i)), real(t1(k)), aimag(t1(k))
            write (1011 + 100*k + 1000*kk_, *) aimag(frequ_(i)), real(t2(k)), aimag(t2(k))
            write (1012 + 100*k + 1000*kk_, *) aimag(frequ_(i)), real(t3(k)), aimag(t3(k))
            if (i == 1 .or. i == 2) then
               write (100, *) - aimag(t_trace1(k, k))/dacos(-1.d0)
               write (101, *) - aimag(t_trace2(k, k))/dacos(-1.d0)
            endif
         enddo

      enddo

      if (size(frequ_) /= n_frequ_long) then
         deallocate (frequ_)
         allocate (frequ_(max(n_frequ_long, n_frequ)))
         frequ_ = (/(inifrequ + dble(j - 1)/dble(size(frequ_) - 1)*deltafrequ, j=1, size(frequ_))/)
      endif

      if (n_frequ /= n_frequ_long) then
         do i = 1, n_frequ_long
            dummy = green_matsu(i, :, :, kk_)
            call invmat(channels, dummy)
            iwplusmu = 0.
            do k = 1, channels
               iwplusmu(k, k) = frequ_(i) + mmu
            enddo
            dummy = dummy + MATMUL(iwplusmu, (Smat(:, :, kk_) - Id(channels)))
            call invmat(channels, dummy)
            tt1(:, :, i) = dummy
         enddo
      endif

      do i1 = 1, channels
         do i2 = 1, channels
            if (i1 == i2) then
               dens(i1, i2) = get_dens(real(tt1(i1, i2, :)), aimag(tt1(i1, i2, :)), diag=.true.)
            else
               dens(i1, i2) = get_dens(real(tt1(i1, i2, :)), aimag(tt1(i1, i2, :)), diag=.false.)
            endif
         enddo
      enddo
      dens = matmul(dens, Smat(:, :, kk_))

      do i1 = 1, channels
         write (102, *) dens(i1, i1)
      enddo

      write (*, *) 'TOTAL DENSITY spin [x] : ', kk_, sum(diag(dens))
      total_density = total_density + sum(diag(dens))

      do i1 = 1, channels
         do i2 = 1, channels
            write (103, '(a,2i4,f16.10)') 'i,j=', i1, i2, dens(i1, i2)
         enddo
      enddo

   enddo

   write (*, *) 'TOTAL DENSITY (UP+DN) : ', total_density

   close (100)
   close (101)
   close (102)
   close (103)

   do kk_ = 1, 2
      do k = 1, channels
         close (1010 + 100*k + 1000*kk_)
         close (1011 + 100*k + 1000*kk_)
         close (1012 + 100*k + 1000*kk_)
      enddo
   enddo

   call finalize_my_simulation
   write (*, *) 'CHECK_CONVERGENCE_FINISHED'

contains

!------------------------!
!------------------------!
!------------------------!
!------------------------!
!------------------------!
   real(kind=DP) function get_dens(GlocRe, GlocIm, diag)
      use linalg, only: mplx
      implicit none
      integer    :: k1, k2, i, j, k, jj
      complex(kind=DP) :: dens
      real(kind=DP)    :: frequ, pi, tau0, omega, df, GlocRe(:), GlocIm(:)
      complex(kind=DP) :: temp
      logical    :: diag
      real(kind=DP)    :: alpha

      pi = dacos(-1.d0)
      jj = size(GlocIm) - 7
      frequ = pi/beta*(2.d0*dble(jj) - 1)
      alpha = -GlocIm(jj)*frequ
      write (*, *) 'GET DENS ALPHA COEF : ', alpha

      tau0 = 1.d-8; dens = 0.d0
      do j = 1, n_frequ_long
         omega = pi/beta*(2.d0*dble(j) - 1.d0)
         if (abs(omega) < 1.d-9) omega = 1.d-9
         temp = CMPLX(GlocRe(j), GlocIm(j), kind=8)
         if (diag) then
            dens = dens + 2.d0/beta*(MPLX(omega*tau0)*(temp + imi/omega*alpha))
         else
            dens = dens + 2.d0/beta*(MPLX(omega*tau0)*(temp))
         endif
      enddo
      if (diag) then
         dens = dens + 0.5*alpha
      endif
      get_dens = dens

      return
   end function

!------------------------!
!------------------------!
!------------------------!
!------------------------!

end program

!======================!
!======================!

