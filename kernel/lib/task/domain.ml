let domain_pool =
    Domainslib.Task.setup_pool
      ~num_domains:(Stdlib.Domain.recommended_domain_count ())
      ()

let async f = Domainslib.Task.async domain_pool f
let await f = Domainslib.Task.await domain_pool f
