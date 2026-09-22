# Open requests

Exported from the request tracker on 8 September. Anyone at Northwind can file
a request here or in the `#northwind-requests` channel. There is no priority
field.

| ID | Opened | From | Request |
|---|---|---|---|
| REQ-0561 | 2 Sep | s.whitcombe | Add `https://embed.webinar-vendor.example` to the partner portal so the webinar signup iframe loads. Third one of these this month. |
| REQ-0562 | 2 Sep | a.belov | I start on the data team on 14 Sep. I need read access to the prod logs and the analytics dataset. |
| REQ-0563 | 30 Aug | m.lindqvist | t.reyes finished their contract on 29 Aug. Their laptop is back. Nothing else has been done. |
| REQ-0564 | 3 Sep | s.whitcombe | New landing page goes live 15 Sep, needs `campaign.northwind.test` pointing at the marketing host. |
| REQ-0565 | 3 Sep | p.raman | Annual rotation of the edge service read-only CI token is overdue. |
| REQ-0566 | 4 Sep | d.okafor | The analytics vendor's integration user needs read access to the export bucket in prod. They sent a service account address. |
| REQ-0567 | 4 Sep | j.tanaka | Please add me to the on-call rotation, I finished shadowing last week. |
| REQ-0568 | 5 Sep | d.okafor | We shipped a header change on Tue. `capture-headers.sh` diffed clean before and after, but the internal dashboard was still logging blocked requests in prod for about 40 minutes afterwards. Not sure what to trust. |
| REQ-0569 | 5 Sep | s.whitcombe | Add `https://cdn.font-vendor.example` for the new brand font on the marketing site. |
| REQ-0570 | 5 Sep | a.belov | Add `https://api.preview.northwind.test` to the preview build allowlist. |
| REQ-0571 | 8 Sep | m.lindqvist | The auditors want a list of everyone with access to the prod project, with the reason and when it was last reviewed. They asked for it in this format last quarter too. |

## Recently closed

The last 20 closed requests, by type:

| Type | Count |
|---|---|
| Add a host or URL to a header allowlist | 7 |
| Grant or remove cloud project access | 5 |
| Add or change a DNS record | 3 |
| Onboard or offboard a person | 3 |
| Something else | 2 |

Median time from request to closed: 6 days. The longest was 19 days.

## Also on the plate

The quarterly access review is due **30 September**. The last one took about
three days of reading `grants.tf`, copying entries into a spreadsheet, mailing
it to each system owner and chasing replies. Two owners never replied and their
entries were carried forward unchanged.
