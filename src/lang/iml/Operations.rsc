module lang::iml::Operations

map[value,value] map_empty() = ();
map[&K, &V] map_union(map[&K, &V] m1, map[&K,&V] m2) = m1 + m2;
map[&K, &V] map_insert(&K k, &V v, map[&K,&V] m) = m + ( k : v );
&V map_lookup(map[&K,&V] m, &K k) = m[k];
map[&K, &V] map_singleton(&K k, &V v) = ( k : v);

list[value] list_nil() = [];
list[value] list_cons(value v, list[value] l) = v + l;

list[value] list_append(list[value] p, value q) = p + q;
list[value] list_append(list[value] p, list[value] q) = p + q;

int int_product(p,q) = int_product([p,q]);
int int_product(Ts) = ( 1 | i * it | int i <- Ts);
int int_sum(int p, int q) = int_sum([p,q]);
int int_sum(Ts) = (0 | i + it | int i <- Ts);
bool int_less_than(int p, int q) = p < q;
bool int_leq(int p, int q) = p <= q;
bool int_geq(int p, int q) = p >= q;
int int_subtract(int p, int q) = p - q;
int succ(int p) = p+1;
int pred(int p) = p-1;

bool bool_neg(bool T) = !T;
bool bool_and(p,q) = bool_and([p,q]);
bool bool_and(Ts) = (  true | B && it | bool B <- Ts);

bool is_map(map[value,value] _) = true;
default bool is_map(_) = false;

bool is_value(value V) = !(node _ := V);
default bool is_map(_) = false;