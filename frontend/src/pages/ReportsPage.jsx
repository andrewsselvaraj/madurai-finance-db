import { useApi } from '../api.js';
import { fmtCurrency } from '../format.js';
import { Bars, EmptyRow, ErrorText, Loading, StatusBadge } from '../components/ui.jsx';

export default function ReportsPage() {
  const { data, error, loading } = useApi('/reports');

  if (error) return <ErrorText message={error} />;
  if (loading || !data) return <Loading />;

  const { loanPortfolio, collectionPerformance, customerStatement } = data;
  if (!loanPortfolio && !collectionPerformance && !customerStatement) {
    return <p className="muted">No reports available.</p>;
  }
  return (
    <>
      {loanPortfolio && <LoanPortfolio report={loanPortfolio} />}
      {collectionPerformance && <CollectionPerformance report={collectionPerformance} />}
      {customerStatement && <CustomerStatement report={customerStatement} />}
    </>
  );
}

function LoanPortfolio({ report }) {
  return (
    <div className="panel">
      <h3>Loan Portfolio Report</h3>
      <Bars buckets={report.byStatus} />
      <table className="data-table">
        <thead><tr><th>Loan</th><th>Customer</th><th>Amount</th><th>Outstanding</th><th>Status</th></tr></thead>
        <tbody>
          {report.loans.length === 0 && <EmptyRow colSpan={5}>No loans.</EmptyRow>}
          {report.loans.map(l => (
            <tr key={l.id}>
              <td>{l.id}</td><td>{l.customerName}</td><td>{fmtCurrency(l.amount)}</td>
              <td>{fmtCurrency(l.outstanding)}</td><td><StatusBadge status={l.status} /></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function CollectionPerformance({ report }) {
  return (
    <div className="panel">
      <h3>Collection Performance Report</h3>
      <p className="muted">Total collected: <strong>{fmtCurrency(report.totalCollected)}</strong></p>
      <h4>By Payment Mode</h4>
      <Bars buckets={report.byMode} />
      <h4>By Collection Agent</h4>
      <Bars buckets={report.byAgent} />
    </div>
  );
}

function CustomerStatement({ report }) {
  return (
    <div className="panel">
      <h3>My Statement</h3>
      <h4>Loans</h4>
      <table className="data-table">
        <thead><tr><th>Loan</th><th>Amount</th><th>Outstanding</th><th>Status</th></tr></thead>
        <tbody>
          {report.loans.length === 0 && <EmptyRow colSpan={4}>No loans.</EmptyRow>}
          {report.loans.map(l => (
            <tr key={l.id}>
              <td>{l.id}</td><td>{fmtCurrency(l.amount)}</td><td>{fmtCurrency(l.outstanding)}</td>
              <td><StatusBadge status={l.status} /></td>
            </tr>
          ))}
        </tbody>
      </table>
      <h4>Payment History</h4>
      <table className="data-table">
        <thead><tr><th>Date</th><th>Loan</th><th>Amount</th><th>Mode</th></tr></thead>
        <tbody>
          {report.payments.length === 0 && <EmptyRow colSpan={4}>No payments yet.</EmptyRow>}
          {report.payments.map(c => (
            <tr key={c.id}>
              <td>{c.date}</td><td>{c.loanId}</td><td>{fmtCurrency(c.amount)}</td><td>{c.paymentMode}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
