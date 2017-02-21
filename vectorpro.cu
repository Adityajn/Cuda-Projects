#include <iostream>
#include <stdlib.h>
#include <stdio.h>
using namespace std;

//__global__ says that function is a kernel which will be executed by GPU by one or more simultaneous thread
// must return void, pass things by reference if you wan value
// only callable form cpu
//threadIDx.x -> within current blk id of current thread in x direction [0 - (num of thread per blk-1) ]
//blockIdx.x -> id of current blk [0 - (numof blks -1) ]
//gridDim.x -> no of blks in x direction in current grid
//blockDim.x -> no of thread in x direction in current blk
__global__ void compute(int *v1,int *v2, int *v3, int N){
	//blockIdx.x (0-2) threadIdx.x (0-99)
	if(blockIdx.x==2){
		v3[(N*blockIdx.x) + threadIdx.x] = v1[((blockIdx.x-2)*N)+threadIdx.x]*v2[((blockIdx.x-1)*N)+threadIdx.x] -
				v1[((blockIdx.x-1)*N)+threadIdx.x]*v2[((blockIdx.x-2)*N)+threadIdx.x];
	}else if(blockIdx.x==1){
		v3[(N*blockIdx.x) + threadIdx.x] = v1[((blockIdx.x+1)*N)+threadIdx.x]*v2[((blockIdx.x-1)*N)+threadIdx.x] -
				v1[(N*(blockIdx.x-1))+threadIdx.x]*v2[((blockIdx.x+1)*N)+threadIdx.x];
	}else{
		v3[(N*blockIdx.x) + threadIdx.x] = v1[((blockIdx.x+1)*N)+threadIdx.x]*v2[((blockIdx.x+2)*N)+threadIdx.x] -
				v2[((blockIdx.x+1)*N)+threadIdx.x]*v1[((blockIdx.x+2)*N)+threadIdx.x];
	}
}

// __host__ says function will be executed by host, all function without prefex are also host function
//only callable from cpu
__host__ void compute2(){    }

//__device__ says function will be executed by kernel once per call
//can be called from gpu only inside kernel or another device function
__device__ void compute3(){   }


int main(){
	int *v1,*v2,*v3;
	int *v1_d,*v2_d, *v3_d;
	v1 = (int*)malloc(sizeof(int)*300);
	v2 = (int*)malloc(sizeof(int)*300);
	v3 = (int*)malloc(sizeof(int)*300);

	int N=100;

	for(int i=0;i<N;i++){
		v1[i]=i*3;v2[i]=i*3+N;
		v1[i+N]=i*3+1;v2[i+N]=i*3+1+N;
		v1[i+2*N]=i*3+2;v2[i+2*N]=i*3+2+N;
	}
	for(int i=0;i<N;i++){
		cout<<v1[i]<<" "<<v1[i+N]<<" "<<v1[i+2*N]<<"\t"<<v2[i]<<" "<<v2[i+N]<<" "<<v2[i+2*N]<<endl;
	}

	cudaMalloc((void**)&v1_d,sizeof(int)*300);
	cudaMalloc((void**)&v2_d,sizeof(int)*300);
	cudaMalloc((void**)&v3_d,sizeof(int)*300);
	cudaMemcpy(v1_d,v1,sizeof(int)*300,cudaMemcpyHostToDevice);
	cudaMemcpy(v2_d,v2,sizeof(int)*300,cudaMemcpyHostToDevice);


	//COMPUTE<<< NO_OF_BLKS , THREADS_PER_BLK >>>	//MAX_THREAD_PER_BLK=1024
	compute<<<3,N>>>(v1_d,v2_d,v3_d,N);	// no_of_blk=3 thread_per_blk=100

	cudaMemcpy(v3,v3_d,sizeof(int)*300,cudaMemcpyDeviceToHost);
	for(int i=0;i<N;i++){
		cout<<v3[i]<<"\t"<<v3[i+N]<<"\t"<<v3[i+N*2]<<endl;
	}
	cout<<"done";
	return 0;
}

/*
 WORK FLOW

 declare variable
 allocate host memory
 allocate device memory for gpu results
 write to host memory
 copy from hot to device
 execute kernel
 write gpu results in hot memory
 free host memory
 free device memory
*/
