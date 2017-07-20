$TTL 5m

;==============================================
; Origin added to names not ending
; in a dot: example.domain.com
;==============================================

@ IN SOA ns.domain.com. administrator.domain.com. (
                1      ; Serial
                1m     ; Refresh after 1 minute
                3m     ; Retry after 3 minutes
                15m    ; Expire after 15 minutes
                1m )   ; Negative caching TTL of 1 minutes

;==============================================
; Name servers (The name '@' is implied)
;==============================================
                NS      ns.domain.com.

;==============================================
; 192.168.1.1 subnet
;==============================================

testa		A	192.168.1.1
testc		CNAME	testa

