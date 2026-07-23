document.addEventListener('DOMContentLoaded', () => {
    console.log('AgentHarness Console - Capability Workbench Prototype initialized.');

    // Add row selection interactivity to the capabilities table
    const tableRows = document.querySelectorAll('.data-table tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('click', () => {
            // Remove selected class from all rows
            tableRows.forEach(r => r.classList.remove('selected'));
            // Add selected class to clicked row
            row.classList.add('selected');
        });
    });
});
