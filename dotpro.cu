#include<stdio.h>
#include<stdlib.h>
#define SIZE 10

__global__ void DotProd(int *a, int *b, int *c)
{
	__shared__ int temp[SIZE];
	int x=threadIdx.x + blockDim.x * blockIdx.x;

	temp[threadIdx.x] = a[x] * b[x];
//	temp[threadIdx.y = a[y] * b[y];

	printf("%d:", temp[x]);
//	printf("%d:", temp[y]);
	
	printf("\n Thread ID : %d ",threadIdx.x);
	__syncthreads();

	if(x==0)
	{
		int i,sum=0;
		for(i=0;i<SIZE;i++)
		{
			sum += temp[i];
		//	atomicAdd(c,sum);
		}
		*c = sum;
		
		printf("\n\n Block Dimensional is : %d ",blockDim);
	        printf("\n\n Block ID : %d ",blockIdx.x);

		printf("\n \n Sum : %d" ,*c); 
	}
}
int main()
{
	int *a,*b,*c;
	int *d_a, *d_b,*d_c;
	int n = SIZE * sizeof(int);
	int i;

	a=(int*)malloc(n);
	b=(int*)malloc(n);
	c=(int*)malloc(sizeof(int));

	for(i=0;i<SIZE;i++)
	{
		a[i]=i+1;
		b[i]=2*(i+1);
	}

	cudaMalloc(&d_a,n);
	cudaMalloc(&d_b,n);
	cudaMalloc(&d_c, sizeof(int));

	cudaMemcpy(d_a, a, n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, n, cudaMemcpyHostToDevice);
	printf("\n Launching kernel :- ");
	DotProd <<<1,SIZE>>> (d_a, d_b, d_c);

	cudaMemcpy(c, d_c, sizeof(int), cudaMemcpyDeviceToHost);
	
	printf("\n Dot Product is : %d \n\n" ,*c);
	
	free(a);
	free(b);
	free(c);
	
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	return 0;
}
