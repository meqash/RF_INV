program main
   use params
   use mt19937
   use fftw
   use model
   use likelihood
   use forward
   use pt_mcmc
   use mcmc_out
   implicit none 
   include "mpif.h"
   integer :: nproc, rank, ierr
   logical :: verb

   ! Initialize MPI 
   call mpi_init(ierr)
   call mpi_comm_size(MPI_COMM_WORLD, nproc, ierr)
   call mpi_comm_rank(MPI_COMM_WORLD, rank,  ierr)
   write(*,*)nproc, rank
   if (nproc < 2) then
      write(0,*)"ERROR: at least 2 processor is necesarry!"
      call mpi_finalize(ierr)
      stop
   end if

   ! Set verbose mode for rank 0
   verb = .false.
   if (rank == 0) verb = .true.  

   !============================================================
   ! Initialize
   !============================================================  
   ! Read parameters from file
   call get_params(verb, "params.in") ! if rank == 0 -> verbose

   ! Read observed files
   call read_obs(verb)

   ! Initialize random number generator
   call sgrnd(iseed)

   ! Initialize FFTW
   call init_fftw()

   ! Make Gaussian low-pass filter
   call init_filter()

   ! Read reference velocity model
   call read_ref_model(verb)

   ! Generate initial model
   call init_model(verb)

   ! Initialize noise sigma
   call init_sig(verb)

   ! Calculate covariacne matrix
   call calc_r_inv(verb)

   ! Initialize temperature
   call init_pt_mcmc(verb)

   !============================================================
   ! MCMC
   !============================================================  

   ! MCMC samping
   call pt_control(verb)
   
   !output
   call output_results(rank, verb)
   
   ! Finish
   call mpi_finalize(ierr)

   stop
 end program main
