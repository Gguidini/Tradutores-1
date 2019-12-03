int fat(int x){
	if(x <= 1){
		return 1;
	}
	return x * fat(x-1);
}


int main(){
	int x;
	inInt x;
	int y;
	y = fat(x);
	outInt y;
}
