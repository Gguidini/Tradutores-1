int prop(int st[], int stmin[], int stmax[], int lazy[], int p, int l, int r) {
	if(lazy[p]) {
		st[p] += lazy[p] * (r - l + 1);
		stmin[p] += lazy[p];
		stmax[p] += lazy[p];
		if(l != r) {
			lazy[2 * p] += lazy[p];
			lazy[2 * p + 1] += lazy[p];
		}
		lazy[p] = 0;
	}
}

int querysum(int st[], int stmin[], int stmax[], int lazy[], int p, int l, int r, int i, int j) {
	prop(st, stmin, stmax, lazy, p, l, r);
	if(l >= i && r <= j){
		return st[p];
	}
	if(i <= r && j >= l){
		int mid;
		mid = (l + r) / 2;
		return querysum(st, stmin, stmax, lazy, 2 * p, l, mid, i, j) + querysum(st, stmin, stmax, lazy, 2 * p + 1, mid + 1, r, i, j);
	}
}

int querymin(int st[], int stmin[], int stmax[], int lazy[], int p, int l, int r, int i, int j) {
	prop(st, stmin, stmax, lazy, p, l, r);
	if(l >= i && r <= j){
		return st[p];
	}
	if(i <= r && j >= l){
		int mid;
		mid = (l + r) / 2;
		return querymin(st, stmin, stmax, lazy, 2 * p, l, mid, i, j) + querymin(st, stmin, stmax, lazy, 2 * p + 1, mid + 1, r, i, j);
	}
}

int querymax(int st[], int stmin[], int stmax[], int lazy[], int p, int l, int r, int i, int j) {
	prop(st, stmin, stmax, lazy, p, l, r);
	if(l >= i && r <= j){
		return st[p];
	}
	if(i <= r && j >= l){
		int mid;
		mid = (l + r) / 2;
		return querymax(st, stmin, stmax, lazy, 2 * p, l, mid, i, j) + querymax(st, stmin, stmax, lazy, 2 * p + 1, mid + 1, r, i, j);
	}
}

int upd(int st[], int stmin[], int stmax[], int lazy[], int p, int l, int r, int i, int j, int val) {
	prop(st, stmin, stmax, lazy, p, l, r);
	if(i > r || j < l) {
		return 0;
	}
	if(l >= i && r <= j) {
		lazy[p] = val;
		prop(st, stmin, stmax, lazy, p, l, r);
		return st[p];
	}
	int mid;
	mid = (l + r) / 2;
	upd(st, stmin, stmax, lazy, 2 * p, l, mid, i, j, val) + upd(st, stmin, stmax, lazy, 2 * p + 1, mid + 1, r, i, j, val);
	st[p] = st[2*p] + st[2*p+1];
}

int main(){
	int st[4000], stmin[4000], stmax[4000], lazy[4000];
	upd(st, stmin, stmax, lazy, 1, 0, 10, 1 1, 100);
}
