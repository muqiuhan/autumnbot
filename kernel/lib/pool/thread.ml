class t =
  object
    val pool =
      Moonpool.Pool.create
        ~min:(Stdlib.Domain.recommended_domain_count () / 2)
        ()

    method async = Moonpool.Pool.run_async pool
  end
