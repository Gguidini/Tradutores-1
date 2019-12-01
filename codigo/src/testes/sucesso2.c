int f(int a, int b[], float c[]){
	return a + b[1];
}

int main(){
	int x[5];
	x[3] = f(1, x, x);
}
