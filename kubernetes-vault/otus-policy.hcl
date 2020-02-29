path "otus/otus-ro/*" {
capabilities = ["read", "list", "update"]
}
path "otus/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}
path "pki_int/*" {
capabilities = ["read", "update", "list"]
}