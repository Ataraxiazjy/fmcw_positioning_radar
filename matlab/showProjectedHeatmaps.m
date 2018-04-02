function showProjectedHeatmaps(hPs,ps,xs,ys,zs)
hPs=figure(hPs);
psYXsum=sum(ps,3);
figure(hPs);
subplot(1,2,1);
imagesc(xs,ys,psYXsum);
axis equal;
axis([min(xs), max(xs), min(ys), max(ys)]);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xyͶӰͼ');
xlabel('x(m)');
ylabel('y(m)');

psXZsum=permute(sum(ps,1),[3,2,1]);
figure(hPs);
subplot(1,2,2);
imagesc(xs,zs,psXZsum);
axis equal;
axis([min(xs), max(xs), min(zs), max(zs)]);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xzͶӰͼ');
xlabel('x(m)');
ylabel('z(m)');
end