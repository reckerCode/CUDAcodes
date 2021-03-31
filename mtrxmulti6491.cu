#include<stdio.h>
#include<cuda.h>
#include<curand.h>
#include<iostream>
#include<stdlib.h>
#include<time.h> 
#include<cstdio>
#include <assert.h>
#define M 6
#define N 4000
#define K 9
#define C 1000
using namespace std;

__global__ void multi_kernel(int *mn,int *m, int *n){
  int xbidx = blockIdx.x;
  int ybidx = blockIdx.y;
  int tidx = threadIdx.x;
  __shared__ int sh_var[N];
  sh_var[tidx] = mn[N * ybidx + tidx] * m[K * tidx + xbidx];
  __syncthreads();

  n[K * ybidx + xbidx ] = 0;
  for(int i = 0; i<N; i++){
      n[K * ybidx + xbidx] = n[K * ybidx + xbidx] + sh_var[i];
      }
  }


int multiplication(){
  int *a,*b,*c;
  int an[M][N];
  int bn[N][K];
  int cn[M][K];
    
  //Generating random Matrix B
  for (int i = 0; i < N; i++){
      for (int  j = 0; j < K; j++){
          bn[i][j] = (int)rand() % 100 * sizeof(int);
      }
  }
  cout << "Matrix B generated" << endl;

  cudaMallocManaged((void **)&b, N * K * sizeof(int));
  cudaMemcpy(b, bn, N * K * sizeof(int), cudaMemcpyHostToDevice);  
  dim3 gridDim(K,M);

  for (int i = 0; i < C; i++){
      for (int k = 0; k < M; k++){
          for (int l = 0; l < N; l++){
              an[k][l] = (int)rand() % 100 * sizeof(int);
              //printf("%d\n", &an[k][l]);
          }
      }
      cudaMallocManaged((void **)&a, M * N * sizeof(int));
      cudaMallocManaged((void **)&c, M * K * sizeof(int));
      cudaMemcpy(a, an, M * N * sizeof(int), cudaMemcpyHostToDevice);
      multi_kernel <<< gridDim, N >>> (a, b, c);
      cudaMemcpy(cn, c, M * K * sizeof(int), cudaMemcpyDeviceToHost);
      
      cudaFree(a);
      cudaFree(c);
  }
  cudaFree(b);
  cout << "Completed Successfully" << endl;
  cout << "[" << M << "] " << "x" << " [" << N << "] " << "*"<< " [" << N << "] "<< "x" <<  " [" << K << "]"<< endl;
  return 0;  
} 

int main(){ 
  time_t start, end, t; 
  start = time(NULL);
 	srand((unsigned) time(&t));
   multiplication();  
  end = time(NULL); 
 // printf("%ld", &end);
  cout << "Total execution time: " << (end-start) << " seconds" << endl;
  return 0;
}