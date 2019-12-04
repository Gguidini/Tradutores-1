int f(int v[], int x){
	v[x] += x;
}

int main(){
	int v[10];
	f(v, 1);
}
