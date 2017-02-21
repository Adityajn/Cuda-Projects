#include<stdio.h>
#define SIZE 10
#define BLOCKS 1
#define THREADS_PER_BLOCK 10

__global__ void oddevensort(int *in, int *out, int size)
{
	bool oddeven=true;
	__shared__ bool swappedodd;
	__shared__ bool swappedeven;
	int temp;
	swappedodd=true;
	swappedeven=true;

	while(true)
	{
		if(oddeven==true)
		{
			printf(" \n Swapping at odd locations ");
			__syncthreads();
			swappedodd=false;
			__syncthreads();

			int idx=threadIdx.x + blockIdx.x * blockDim.x;
			if(idx < (size / 2))
			{
				if(in[2 * idx] > in[2 * idx +1])
				{
					printf("\n Thread Id %d : is swapping %d <-> %d  \n Thread Id %d : [%d] <-> [%d] \n ", idx, in[2 * idx] ,  in[2 * idx + 1], idx, 2 * idx, (2 * idx +1));		

					temp = in[2 * idx];
					in [2 * idx]= in[2 * idx + 1];
					in [2 * idx + 1]=temp;
					swappedodd = true;
				}
			}

			__syncthreads();
		}

		else
		{
			//printf("Swapping at even locations \n ");
			__syncthreads();
			swappedeven=false;
			__syncthreads();

			int idx=threadIdx.x + blockIdx.x * blockDim.x;
			if(idx < (size / 2) - 1)
			{
				if(in[2 * idx + 1] > in[2 * idx +2])
				{
					printf("\n Thread Id %d : is swapping %d <-> %d  \n Thread Id %d : [%d] <-> [%d] \n ", idx, in[2 * idx + 1] ,  in[2 * idx + 2], idx, 2 * idx + 1, (2 * idx +2));		

					temp = in[2 * idx + 1];
					in [2 * idx + 1]= in[2 * idx + 2];
					in [2 * idx + 2] = temp;
					swappedeven=true;
				}
			}
			__syncthreads();
		}

		if(!(swappedodd || swappedeven ))
		break;
		oddeven = !oddeven;
	}

	__syncthreads();

	int idx =threadIdx.x;

	if(idx < size)
		out[idx] = in[idx];
}

int main(void)
{
	int *a, *a_sorted, i;
	int *d_a, *d_sorted;
	int size = sizeof(int)*SIZE;
	
	cudaMalloc((void**)&d_a, size);
	cudaMalloc((void**)&d_sorted, size);

	a = (int*)malloc(size);
	a_sorted = (int*)malloc(size);

	cudaMalloc((void**)&d_sorted,size);
        
	printf("\n Enter % d numbers to sort : \n",SIZE);
	for(i=0 ; i<SIZE; i++)
	{
		scanf("%d", &a[i]);
	}

	printf("\n Unsorted array is : \n");
	for(i=0 ; i<SIZE; i++)
	{
		printf("%d ", a[i]);
	}

	cudaMemcpy(d_a,a,size,cudaMemcpyHostToDevice);
	oddevensort<<<BLOCKS,THREADS_PER_BLOCK>>>(d_a,d_sorted,SIZE);
	cudaMemcpy(a,d_a,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(a_sorted,d_sorted,size,cudaMemcpyDeviceToHost);
	
	printf("\n \n Sorted array is : \n");
	for(i=0 ; i<SIZE; i++)
	{
		printf("%d ", a_sorted[i]);
	}
	
	printf("\n\n");

	free(a);
	free(a_sorted);

	cudaFree(d_sorted);
	cudaFree(d_a);
	
	return 0;
}
