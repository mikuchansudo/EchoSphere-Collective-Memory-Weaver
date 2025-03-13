document.addEventListener('DOMContentLoaded', () => {
    fetchMemories();

    document.getElementById('memoryForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const memory = document.getElementById('memoryInput').value;
        if (memory.trim() !== '') {
            submitMemory(memory);
        }
    });
});

function fetchMemories() {
    fetch('/memories')
        .then(response => response.json())
        .then(data => {
            const memoriesDiv = document.getElementById('memories');
            memoriesDiv.innerHTML = '';
            data.forEach(memory => {
                const p = document.createElement('p');
                p.textContent = memory.text;
                memoriesDiv.appendChild(p);
            });
        })
        .catch(err => console.error('Error fetching memories:', err));
}

function submitMemory(memory) {
    fetch('/memories', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text: memory }),
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById('memoryInput').value = '';
        fetchMemories();
    })
    .catch(err => console.error('Error submitting memory:', err));
}